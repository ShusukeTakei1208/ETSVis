script <- sub("^--file=","",grep("^--file=",commandArgs(FALSE),value=TRUE))
root <- dirname(dirname(normalizePath(script)))
d <- read.csv(file.path(root,"output/trade_consumption_17regions.csv"))
codes <- unique(d$region)
draw <- function(){
 layout(matrix(1:20,nrow=4,byrow=TRUE))
 par(mar=c(2.4,3.1,1.7,.6),oma=c(4.8,2,3.4,.2),family="sans",las=1,mgp=c(1.8,.4,0),tcl=-.2)
 for(r in codes){
   z <- d[d$region==r,]; z <- z[order(z$year),]
   a <- z$net_payment_billion_model_base_USD_per_year
   b <- z$additional_consumption_loss_billion_model_base_USD_per_year
   lim <- range(0,a,b); pad <- max(diff(lim)*.08,.1)
   plot(z$year,a,type="n",xlim=c(2035,2100),ylim=lim+c(-pad,pad),
        axes=FALSE,xlab="",ylab="",main=z$name[1],cex.main=.94)
   abline(h=pretty(lim),col="#EEEEEE",lwd=.6)
   abline(h=0,col="#999999",lwd=.7)
   lines(z$year,a,col="#2463A6",lwd=1.7)
   lines(z$year,b,col="#D55E00",lwd=1.7,lty=1)
   obs <- z$year %% 5 == 0
   points(z$year[obs],a[obs],col="#2463A6",pch=19,cex=.85)
   points(z$year[obs],b[obs],col="#D55E00",pch=19,cex=.85)
   axis(1,at=c(2035,2050,2075,2100),cex.axis=.7)
   axis(2,cex.axis=.72)
   box(col="#CCD3DB")
 }
 par(mar=rep(0,4))
 for(i in 1:3) plot.new()
 mtext("Allowance trade and consumption effects",3,outer=TRUE,line=1.65,adj=.02,font=2,cex=1.4)
 mtext("Billion USD / year (model base year: 2005)",2,outer=TRUE,line=.25,las=0,cex=.9)
 mtext("Year",1,outer=TRUE,line=.5)
 # Use the three empty bottom-right panels for a readable shared legend.
 par(oma=rep(0,4),fig=c(.41,.99,.11,.26),new=TRUE,mar=rep(0,4))
 plot.new()
 legend("center",c("Net allowance payments","Additional consumption loss"),
        col=c("#2463A6","#D55E00"),lty=1,pch=19,pt.cex=1.1,
        lwd=2.4,bty="n",cex=1.5,y.intersp=1.45,seg.len=2.7)
}
stem <- file.path(root,"output/trade_consumption_17regions_slide")
png(paste0(stem,".png"),width=3200,height=1800,res=200)
draw()
dev.off()
pdf(paste0(stem,".pdf"),width=16,height=9)
draw()
dev.off()
