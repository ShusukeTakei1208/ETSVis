script <- sub('^--file=','',grep('^--file=',commandArgs(FALSE),value=TRUE))
root <- dirname(dirname(normalizePath(script)));out <- file.path(root,'output')
d <- read.csv(file.path(out,'CDR_CCS_indicator_check_old.csv'))
regions <- read.csv(file.path(out,'power_cost_old_trade_classification_2050.csv'))
ids <- c('SSP2_2020NDC_NZE_NoCC_No','SSP2_2020_NZE_test_NoCC_No')
specs <- list(CDR=c('BECCS'='Car_Seq_CCS_Bio','DACCS'='Car_Seq_Dir_Air_Cap','Enhanced weathering'='Car_Seq_Enh_Wea','Afforestation / forest management'='Car_Seq_Lan_Use_Aff','Biochar'='Car_Seq_Lan_Use_Bio','Soil carbon'='Car_Seq_Lan_Use_Soi_Car_Man'),CCS=c('Biomass'='Car_Seq_CCS_Bio','Direct air capture'='Car_Seq_Dir_Air_Cap','Fossil fuels'='Car_Seq_CCS_Fos','Industrial processes'='Car_Seq_CCS_Ind_Pro'))
palettes <- list(CDR=c('#00D800','#258FF0','#B88708','#248627','#FF1717','#A51DE0'),CCS=c('#00D800','#258FF0','#FF1717','#248627'))
template <- paste(readLines(file.path(root,'prog/plot_primary_energy_old_2050_annual_groups_slide.R')),collapse='\n')
code <- substring(template,regexpr('stopifnot(nrow(energy)',template,fixed=TRUE)[1])
checks <- list()
selected <- commandArgs(trailingOnly=TRUE)
if(!length(selected)) selected <- names(specs)
stopifnot(all(selected %in% names(specs)))
for(kind in selected){
 spec <- specs[[kind]];palette <- setNames(palettes[[kind]],names(spec))
 energy <- d[d$year==2050 & d$region %in% regions$region & d$scenario %in% ids & d$variable %in% unname(spec),]
 stopifnot(all(energy$unit=='Mt CO2/yr'))
 energy$scenario <- c('NZE_w/oET','NZE_w/ET')[match(energy$scenario,ids)]
 energy$category <- names(spec)[match(energy$variable,unname(spec))]
 energy$value_EJ_per_year <- energy$value/1000 # Layout's generic value column; actual unit is Gt CO2/year.
 sums <- aggregate(value~scenario+region,energy,sum)
 total <- d[d$year==2050 & d$region %in% regions$region & d$scenario %in% ids & d$variable==paste0('Car_Seq_',kind),]
 total$scenario <- c('NZE_w/oET','NZE_w/ET')[match(total$scenario,ids)]
 sums$reported_total_MtCO2_per_year <- total$value[match(paste(sums$scenario,sums$region),paste(total$scenario,total$region))]
 sums$residual <- sums$value-sums$reported_total_MtCO2_per_year
 stopifnot(nrow(sums)==34,max(abs(sums$residual))<1e-7)
 sums$type <- kind;checks[[kind]] <- sums
 run <- gsub('17*2*15',paste0('17*2*',length(spec)),code,fixed=TRUE)
 run <- gsub('2050 primary energy',paste('2050',kind,'use'),run,fixed=TRUE)
 run <- gsub('primary_energy_old_2050_annual_groups',paste0(kind,'_old_2050_annual_groups'),run,fixed=TRUE)
 run <- gsub('Unit: EJ/year. Previous model results. Groups use net allowance payments in 2050.','Unit: Gt CO2/year (annual flow, not cumulative). Source: global_17_IAMC.gdx. Groups: 2050 net payments.',run,fixed=TRUE)
 run <- gsub('ncol=4','ncol=2',run,fixed=TRUE)
 run <- gsub('(EJ/year)','(GtCO2/year)',run,fixed=TRUE)
 run <- gsub('cex=.67','cex=.75',run,fixed=TRUE)
 eval(parse(text=run))
 names(energy)[names(energy)=='value_EJ_per_year'] <- 'value_GtCO2_per_year'
 write.csv(energy[c('region','scenario','variable','category','value_GtCO2_per_year','trade_group_2050')],file.path(out,paste0(kind,'_old_2050_by_technology.csv')),row.names=FALSE)
}
write.csv(do.call(rbind,checks),file.path(out,'CDR_CCS_old_2050_balance_checks.csv'),row.names=FALSE)
