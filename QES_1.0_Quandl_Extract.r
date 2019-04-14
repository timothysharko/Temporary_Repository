#
# QES_1.0_Extract.R - Global Equity Markets 
#

#
library (Quandl)
library (quantmod)
library (timeSeries)
library (zoo)

#
# Define scenario start and end dates
#
scenario_start_date             <-'2003-12-01'
scenario_end_date               <-'2018-05-11'

#
# Define working storage
#
scenario_name               <-'QES'
scenario_version_number     <-'1.0'
filename_base               <-paste(scenario_name,scenario_version_number,sep="_")
filename_assets             <-paste(scenario_name,scenario_version_number,"assets.csv",sep="_")
filename_daily_data         <-paste(scenario_name,scenario_version_number,"ddata.csv",sep="_")
filename_daily_prices       <-paste(scenario_name,scenario_version_number,"dprices.csv",sep="_")
filename_daily_prices_raw   <-paste(scenario_name,scenario_version_number,"dprices_raw.csv",sep="_")
filename_daily_returns      <-paste(scenario_name,scenario_version_number,"dreturns.csv",sep="_")
filename_weekly_data        <-paste(scenario_name,scenario_version_number,"wdata.csv",sep="_")
filename_weekly_prices      <-paste(scenario_name,scenario_version_number,"wprices.csv",sep="_")
filename_weekly_returns     <-paste(scenario_name,scenario_version_number,"wreturns.csv",sep="_")
filename_monthly_data       <-paste(scenario_name,scenario_version_number,"mdata.csv",sep="_")
filename_monthly_prices     <-paste(scenario_name,scenario_version_number,"mprices.csv",sep="_")
filename_monthly_returns    <-paste(scenario_name,scenario_version_number,"mreturns.csv",sep="_")
filename_quarterly_data     <-paste(scenario_name,scenario_version_number,"qdata.csv",sep="_")
filename_quarterly_prices   <-paste(scenario_name,scenario_version_number,"qprices.csv",sep="_")
filename_quarterly_returns  <-paste(scenario_name,scenario_version_number,"qreturns.csv",sep="_")
filename_yearly_data        <-paste(scenario_name,scenario_version_number,"ydata.csv",sep="_")
filename_yearly_prices      <-paste(scenario_name,scenario_version_number,"yprices.csv",sep="_")
filename_yearly_returns     <-paste(scenario_name,scenario_version_number,"yreturns.csv",sep="_")

#
# Establish authorization with Quandl
#
Quandl.api_key("Quandl API Key Goes Here")

#
# Read asset names from asset names file
#
assetdata.df <-read.csv(file=filename_assets,head=TRUE,sep=",")

#
# Select daily prices
#
dprices.xts <-Quandl(c(
'FRED/DTB3.1',
'NASDAQOMX/NQGI.1',
'NASDAQOMX/NQAU.1',
'NASDAQOMX/NQCA.1',
'NASDAQOMX/NQCN.1',
'NASDAQOMX/NQCZ.1',
'NASDAQOMX/NQEG.1',
'NASDAQOMX/NQFI.1',
'NASDAQOMX/NQFR.1',
'NASDAQOMX/NQDE.1',
'NASDAQOMX/NQGR.1',
'NASDAQOMX/NQHK.1',
'NASDAQOMX/NQIN.1',
'NASDAQOMX/NQID.1',
'NASDAQOMX/NQIL.1',
'NASDAQOMX/NQJP.1',
'NASDAQOMX/NQKR.1',
'NASDAQOMX/NQMY.1',
'NASDAQOMX/NQNL.1',
'NASDAQOMX/NQPH.1',
'NASDAQOMX/NQPL.1',
'NASDAQOMX/NQPT.1',
'NASDAQOMX/NQRU.1',
'NASDAQOMX/NQSG.1',
'NASDAQOMX/NQES.1',
'NASDAQOMX/NQSE.1',
'NASDAQOMX/NQCH.1',
'NASDAQOMX/NQTW.1',
'NASDAQOMX/NQTH.1',
'NASDAQOMX/NQTR.1',
'NASDAQOMX/NQGB.1'
),
type="xts",
order="asc",
start_date = '2003-12-01',
end_date = '2018-05-11'
)
head(dprices.xts)
tail(dprices.xts)

#
# Write daily prices
#
colnames (dprices.xts) <-assetdata.df[,2]
write.zoo(dprices.xts,filename_daily_prices_raw,index.name="Date",row.names=FALSE,col.names=TRUE,sep=",",append=FALSE)

#
# Read daily price data
#
prices.tS            <-as.timeSeries(dprices.xts)
prices.tS            <-window(prices.tS, start = scenario_start_date , end = scenario_end_date)
prices.tS            <-timeSeries(prices.tS) #, zone="America/New_York",FinCenter="America/New_York")
prices.ALN           <-align(x=prices.tS,by='1d',method='before',include.weekends=FALSE)
prices.tS            <-prices.ALN
prices.xts           <-as.xts(prices.tS)
head(dprices.xts)
tail(dprices.xts)

#
# Compute returns for Rmetrics - timeSeries
#
returns.tS <-returns(prices.tS,method = 'discrete')

#
# Set non finite values (NaN, -Inf, Inf) to zero
#
which(!is.finite(returns.tS))
returns.tS[which(!is.finite(returns.tS))]<-0
which(!is.finite(returns.tS))
returns100.tS <-100 * returns.tS

#
# Define prices and returns for performance analytics - xts
#
prices.xts  <-as.xts(prices.tS)
returns.xts <-as.xts(returns.tS)

#
# Write output files
#
write.zoo(as.xts(prices.tS),filename_daily_prices,index.name='Date',sep=",")
write.zoo(as.xts(returns.tS),filename_daily_returns,index.name='Date',sep=",")

#

#
# End of job
#
