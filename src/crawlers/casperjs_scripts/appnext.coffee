casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper
#useful during development
#different messages
#casper.enableDebug()
params = helper.params
start_date = params.start_date.format('YYYY-MM-DD')
end_date = params.end_date.format('YYYY-MM-DD')
queryData =
  type:"Date"
  dates:[start_date,start_date]
  from:start_date
  to:start_date
  platform:""
  apps:""
  path:"GetReport"
casper.start 'https://selfservice.appnext.com/Account/Login.aspx?ReturnUrl=%2fDashboard.aspx', ->
  this.fill 'form#form1',
    username: params.username
    password: params.password
  , true

casper.waitForUrl /Dashboard.aspx/, ->
casper.thenOpen 'https://selfservice.appnext.com/Revenue/Service.asmx/GetReport', {method:'POST', data: queryData}, ->
  content = this.getPageContent().replace /<(.|\n)*?>/g, ''
  content_parsed = JSON.parse content
  if content_parsed[0]
    data =
      impressions: str_parser.toInt content_parsed[0].Impressions
      requests: str_parser.toInt content_parsed[0].Impressions
      clicks: str_parser.toInt content_parsed[0].Clicks
      revenue: str_parser.toFloat content_parsed[0].Earning
      currency: 'USD'
  else
    data =
      impressions: 0
      requests: 0
      clicks: 0
      revenue: 0
      currency: 'USD'
  helper.returnData data

casper.run()