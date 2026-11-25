script <- sub("^--file=","",grep("^--file=",commandArgs(FALSE),value=TRUE))
root <- dirname(dirname(normalizePath(script)))
regions <- read.csv(file.path(root,"output/power_cost_old_trade_classification_2050.csv"))
energy <- read.csv(file.path(root,"output/primary_energy_mix_three_dates_2050.csv"))
energy <- subset(energy,region %in% regions$region & scenario %in% c("NZE_w/oET","NZE_w/ET"))
palette <- c("Coal without CCS"="#202020","Coal with CCS"="#939BA3",
 "Oil without CCS"="#F04416","Oil with CCS"="#FFB0A3",
 "Gas without CCS"="#940087","Gas with CCS"="#D891D1",
 "Hydro"="#1457ED","Nuclear"="#A15A09","Solar"="#9BE4F5","Wind"="#FF9B00",
 "Biomass without CCS"="#2FA36D","Biomass with CCS"="#A7D875",
 "Geothermal"="#E8C28D","Other"="#F6E8A5","Net secondary energy trade"="#64748B")
stopifnot(nrow(energy)==17*2*15,!anyDuplicated(energy[c("region","scenario","category")]),
          all(energy$category %in% names(palette)),all(is.finite(energy$value_EJ_per_year)))
energy$category <- factor(energy$category,levels=names(palette))
energy$scenario <- factor(energy$scenario,levels=c("NZE_w/oET","NZE_w/ET"))
values <- xtabs(value_EJ_per_year~category+scenario+region,energy)
energy$trade_group_2050 <- regions$group[match(energy$region,regions$region)]
write.csv(energy,file.path(root,"output/primary_energy_old_2050_annual_groups.csv"),row.names=FALSE)
draw <- function(){
 buyers <- subset(regions,group=="Buyer")
 sellers <- subset(regions,group=="Seller")
 par(oma=rep(0,4),family="sans",las=1)
 plot.new()
 panel <- function(region,column,row){
   left <- .028+(column-1)*.972/6
   top <- .93-(row-1)*.205
   par(fig=c(left,left+.972/6,top-.197,top),new=TRUE,
       mar=c(1.35,2.35,1.05,.45),mgp=c(2.1,.45,0),tcl=-.2)
   m <- values[,,region$region]
   positive <- colSums(pmax(m,0))
   negative <- colSums(pmin(m,0))
   span <- max(positive)-min(0,negative)
   limits <- c(min(0,negative)-.02*span,max(positive)+.07*span)
   plot(NA,xlim=c(.5,2.5),ylim=limits,axes=FALSE,xlab="",ylab="",
        main=region$region_name,cex.main=.72,xaxs="i",yaxs="i")
   ticks <- pretty(limits,n=4)
   abline(h=ticks,col="#EEEEEE",lwd=.5)
   for(j in 1:2){
     up <- cumsum(pmax(m[,j],0)); down <- cumsum(pmin(m[,j],0))
     rect(j-.29,up-pmax(m[,j],0),j+.29,up,col=palette,border=NA)
     rect(j-.29,down,j+.29,down-pmin(m[,j],0),col=palette,border=NA)
   }
   abline(h=0,col="#888888",lwd=.5)
   axis(1,at=1:2,labels=c("NZE_w/oET","NZE_w/ET"),cex.axis=.58,col="#CCCCCC")
   axis(2,at=ticks,cex.axis=.58,col="#CCCCCC")
   box(col="#DDDDDD")
 }
 for(i in seq_len(nrow(buyers)))panel(buyers[i,],(i-1)%%3+1,(i-1)%/%3+1)
 for(i in seq_len(nrow(sellers)))panel(sellers[i,],(i-1)%%3+4,(i-1)%/%3+1)
 par(fig=c(0,1,0,1),new=TRUE,mar=rep(0,4),xaxs="i",yaxs="i")
 plot.new()
 text(.25,.975,"2050 primary energy | Net buyers in 2050",font=2,cex=.95)
 text(.75,.975,"2050 primary energy | Net sellers in 2050",font=2,cex=.95)
 text(.012,.55,"(EJ/year)",srt=90,cex=.95)
 text(.18,.035,"Horizontal axis: Scenario",cex=.8)
 legend(.37,.25,legend=names(palette),fill=palette,border=NA,ncol=4,bty="n",
        cex=.85,xjust=0,yjust=1,x.intersp=.6,y.intersp=1.05)
 text(.65,.035,"Previous model results. Groups use net allowance payments in 2050.",
      cex=.65,col="#465261")
}
stem <- file.path(root,"output/primary_energy_old_2050_annual_groups_slide")
png(paste0(stem,".png"),width=3200,height=1750,res=200)
draw()
dev.off()
pdf(paste0(stem,".pdf"),width=16,height=8.75)
draw()
dev.off()
