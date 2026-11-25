root <- 'C:/AIMHub_fig'
d <- read.csv(file.path(root,'output/emission_paths_old_source.csv'))
d <- subset(d,variable=='Emi_CO2')
ids <- c('SSP2_2020NDC_NZE_NoCC_No','SSP2_2020_NZE_test_NoCC_No')
labs <- c('NZE_w/oET','NZE_w/ET'); cols <- c('#FF0000','#A8E68C')
codes <- c('World','JPN','USA','CAN','XE25','XOC','TUR','XER','CIS','CHN','IND','XSE','XSA','BRA','XLM','XME','XNF','XAF')
cl <- read.csv(file.path(root,'output/power_cost_old_trade_classification_2050.csv'))
render <- function(){
 par(mfrow=c(3,6),mar=c(2.5,3,2,.6),oma=c(4.2,1,2.5,.2),family='sans',mgp=c(2,.5,0))
 for(r in codes){
  use_ids <- if(r=='World') c('SSP2_BaU_NoCC_No',ids) else ids
  use_cols <- if(r=='World') c('#1457ED',cols) else cols
  z <- subset(d,region==r & scenario %in% use_ids)
  lim <- range(0,z$value_Mt_per_year/1000)
  pad <- max(diff(lim)*.06,.002)
  plot(NA,xlim=c(2026,2100),ylim=lim+c(-pad,pad),axes=FALSE,xlab='',ylab='',xaxs='i')
  abline(h=pretty(lim),col='#EEEEEE',lwd=.7)
  abline(h=0,col='#888888',lwd=.7)
  for(i in seq_along(use_ids)){
   a<-subset(z,scenario==use_ids[i]);a<-a[order(a$year),]
   stopifnot(nrow(a)==16,all(is.finite(a$value_Mt_per_year)))
   yy<-approx(a$year,a$value_Mt_per_year/1000,xout=2026:2100)$y
   lines(2026:2100,yy,col=use_cols[i],lwd=2,lty=1)
   obs <- a[a$year>=2030,]
   points(obs$year,obs$value_Mt_per_year/1000,col=use_cols[i],pch=19,cex=.9)
  }
  axis(1,at=c(2026,2050,2075,2100),cex.axis=.77)
  axis(2,las=1,cex.axis=.77)
  box(col='#CCCCCC');title(main=if(r=='World')'World' else cl$region_name[match(r,cl$region)],cex.main=.93)
 }
 mtext('World and regional CO2 emission pathways',3,outer=TRUE,line=1,font=2,cex=1.3)
 mtext('GtCO2/year',2,outer=TRUE,line=0,cex=.85)
 mtext('Year',1,outer=TRUE,line=.1,cex=.9)
 par(oma=rep(0,4),fig=c(0,1,0,.052),new=TRUE,mar=rep(0,4));plot.new()
 # Fixed-width legend slots keep the three entries equally spaced.
 par(usr=c(0,1,0,1))
 for(i in 1:3){
  center <- c(.35,.5,.65)[i]
  segments(center-.065,.66,center-.045,.66,col=c('#1457ED',cols)[i],lwd=2.5)
  points(center-.055,.66,col=c('#1457ED',cols)[i],pch=19,cex=.9)
  text(center-.035,.66,c('BaU',labs)[i],adj=c(0,.5),cex=1.4)
 }
 text(.5,.12,'Previous results | Emi_CO2 | Dots: 5-year IAMC outputs; lines connect observations | World uses the stored IAMC World series',cex=.65,col='#465261')
}
stem<-file.path(root,'output/regional_CO2_emission_paths_old_slide_world')
png(paste0(stem,'.png'),width=16,height=9,units='in',res=200);render();dev.off()
pdf(paste0(stem,'.pdf'),width=16,height=9);render();dev.off()
write.csv(subset(d,scenario %in% ids | (region=='World' & scenario=='SSP2_BaU_NoCC_No')),paste0(stem,'_source.csv'),row.names=FALSE)
