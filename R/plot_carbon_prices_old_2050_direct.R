script <- sub("^--file=","",grep("^--file=",commandArgs(FALSE),value=TRUE))
root <- dirname(dirname(normalizePath(script)))
d <- read.csv(file.path(root,"output/carbon_prices_old_2050_direct.csv"))
codes <- c("JPN","USA","CAN","XE25","XOC","TUR","XER","CIS","CHN","IND","XSE","XSA","BRA","XLM","XME","XNF","XAF")
regions <- c("Japan","United States","Canada","EU25","Oceania","Turkey","Rest of Europe","Former Soviet Union","China","India","Southeast Asia","Rest of Asia","Brazil","Rest of South America","Middle East","North Africa","Rest of Africa")
stopifnot(nrow(d)==17,!anyDuplicated(d$region),setequal(d$region,codes))
d <- d[match(codes,d$region),]
a <- d$NZE_without_ET_USD_per_tCO2eq
b <- d$NZE_with_ET_USD_per_tCO2eq
stopifnot(all(is.finite(a)),all(is.finite(b)),length(unique(b))==1)
draw <- function(){
 par(mar=c(10.5,5.2,4.1,1),family="sans",mgp=c(2.9,.65,0),las=1)
 lim <- c(0,max(a,b)*1.1)
 plot(NA,xlim=c(.5,17.5),ylim=lim,xaxs="i",axes=FALSE,xlab="",ylab="Carbon price (USD / tCO2e)")
 abline(h=pretty(lim),col="#EEEEEE")
 abline(h=b[1],col="#777777",lwd=1)
 segments(1:17,a,1:17,b,lty=2,col="#555555")
 points(1:17,a,pch=19,col="#1457ED",cex=1.1)
 points(1:17,b,pch=4,col="#1457ED",cex=1.15,lwd=1.6)
 axis(2,at=pretty(lim))
 axis(1,at=1:17,labels=FALSE)
 text(1:17,par("usr")[3]-.075*diff(par("usr")[3:4]),regions,
      srt=45,adj=c(1,1),xpd=NA,cex=.87)
 box(col="#AAAAAA")
 mtext("Regional carbon prices and the international ET price in 2050",3,line=2,font=2,adj=0,cex=1.25)
 par(fig=c(0,1,0,.065),new=TRUE,mar=rep(0,4))
 plot.new()
 legend("center",legend=c("NZE_w/oET","NZE_w/ET"),col=c("#1457ED","#1457ED"),pch=c(19,4),pt.cex=c(1.1,1.15),pt.lwd=c(1,1.6),horiz=TRUE,bty="n")
}
stem <- file.path(root,"output/carbon_prices_old_2050")
png(paste0(stem,".png"),width=2600,height=1400,res=180)
draw()
dev.off()
pdf(paste0(stem,".pdf"),width=14.444,height=7.778)
draw()
dev.off()


