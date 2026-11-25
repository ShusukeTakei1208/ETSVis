args <- grep("^--file=",commandArgs(FALSE),value=TRUE)
setwd(normalizePath(file.path(dirname(sub("^--file=","",args)),"..")))
# Run from the project root. Uses the verified technology-level cost CSV.
cost <- read.csv("output/power_cost_2050_complete_by_technology.csv", fileEncoding="UTF-8-BOM")
regions <- read.csv("output/power_cost_old_trade_classification_2050.csv")
# Reuse the verified 2050 payment extraction for this presentation-only edit.
regions$group <- ifelse(regions$payment_2050_billion_USD>0,"Buyer","Seller")
write.csv(regions,"output/power_cost_old_trade_classification_2050.csv",row.names=FALSE)
scenarios <- c("SSP2_2020NDC_NZE_NoCC_No", "SSP2_2020_NZE_test_NoCC_No")
scenario_labels <- c("NZE_w/oET", "NZE_w/ET")
palette <- c(
  "Coal without CCS"="#202020", "Coal with CCS"="#939BA3",
  "Oil without CCS"="#F04416", "Oil with CCS"="#FFB0A3",
  "Gas without CCS"="#940087", "Gas with CCS"="#D891D1",
  "Hydro"="#1457ED", "Nuclear"="#A15A09", "Solar PV"="#9BE4F5",
  "Wind"="#FF9B00", "Biomass without CCS"="#2FA36D",
  "Biomass with CCS"="#A7D875", "Geothermal"="#E8C28D",
  "Other renewables"="#F6E8A5"
)
cost$category <- cost$technology
cost$category[cost$technology %in% c("Onshore wind", "Offshore wind")] <- "Wind"
cost$category[cost$technology %in% c("Conventional biomass", "Advanced biomass without CCS")] <- "Biomass without CCS"
stopifnot(all(cost$category %in% names(palette)), all(is.finite(cost$cost_billion_USD2010)),
          setequal(cost$scenario, scenarios), setequal(cost$region, regions$region),
          nrow(regions)==17, all(regions$group %in% c("Buyer", "Seller")))
cost$category <- factor(cost$category, levels=names(palette))
cost$scenario <- factor(cost$scenario, levels=scenarios)
values <- xtabs(cost_billion_USD2010 ~ category + scenario + region, cost)
stopifnot(isTRUE(all.equal(sum(values), sum(cost$cost_billion_USD2010))))

draw <- function(){
  buyers <- subset(regions,group=="Buyer")
  sellers <- subset(regions,group=="Seller")
  # Six columns place the two region groups side by side.
  par(oma=c(0,0,0,0),family="sans",las=1)
  panel <- function(region, column, row){
    left <- .028+(column-1)*.972/6
    top <- .93-(row-1)*.205
    par(fig=c(left,left+.972/6,top-.197,top),new=TRUE,
        mar=c(1.35,2.35,1.05,.45),mgp=c(2.1,.45,0),tcl=-.2)
    m <- values[,,region$region]
    ymax <- max(colSums(m))*1.1
    plot(NA,xlim=c(.5,2.5),ylim=c(0,ymax),axes=FALSE,xlab="",ylab="",
         main=region$region_name,cex.main=.72,xaxs="i",yaxs="i")
    ticks <- pretty(c(0,ymax),n=4)
    abline(h=ticks,col="#EEEEEE",lwd=.5)
    for(j in 1:2){
      top <- cumsum(m[,j])
      rect(j-.29,top-m[,j],j+.29,top,col=palette,border=NA)
    }
    axis(1,at=1:2,labels=scenario_labels,cex.axis=.58,col="#CCCCCC")
    axis(2,at=ticks,cex.axis=.58,col="#CCCCCC")

    box(col="#DDDDDD")
  }
  plot.new()
  for(i in seq_len(nrow(buyers))) panel(buyers[i,],(i-1)%%3+1,(i-1)%/%3+1)
  for(i in seq_len(nrow(sellers))) panel(sellers[i,],(i-1)%%3+4,(i-1)%/%3+1)
  par(fig=c(0,1,0,1),new=TRUE,mar=rep(0,4),xaxs="i",yaxs="i")
  plot.new()
  text(.25,.975,"2050 generation cost | Net buyers in 2050",font=2,cex=.95)
  text(.75,.975,"2050 generation cost | Net sellers in 2050",font=2,cex=.95)

  # Legend occupies the blank space to the right of the last buyer row.
  text(.012,.55,"(billion USD2010/year)",srt=90,cex=.95)
  text(.18,.035,"Horizontal axis: Scenario",cex=.8)
  legend(x=.37,y=.25,legend=names(palette),fill=palette,border=NA,
         ncol=4,bty="n",cex=.85,xjust=0,yjust=1,x.intersp=.6,y.intersp=1.05)
  text(.65,.035,"Groups use 2050 net payments. LCOE x generation; grid and storage excluded.",
       cex=.63,col="#465261")
}
stem <- "output/power_cost_2050_old_annual_groups_slide"
png(paste0(stem,".png"),width=3200,height=1750,res=200)
draw()
dev.off()
pdf(paste0(stem,".pdf"),width=16,height=8.75)
draw()
dev.off()



