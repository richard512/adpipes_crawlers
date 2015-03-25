casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper
#useful during development
#different messages
#casper.enableDebug()
params = helper.params
casper.options.timeout = 100000
start_date = params.start_date.format 'DD/MM/YYYY'
end_date = params.end_date.format 'DD/MM/YYYY'
loginUrl = 'https://ads.epom.com/j_spring_security_check.do'
dataUrl = 'https://ads.epom.com/account/epom-market-analytics/search.do'
data =
  j_username: params.username
  j_password: params.password
data1 =
  range: "CUSTOM"
  customFrom: start_date
  customTo: end_date
  userNameSearch: params.username
  groupRange: "NONE"
  groupBy: ""
  searchField: ""

casper.start 'https://ads.epom.com/login.do', ->
casper.thenOpen loginUrl, {method: 'POST', data: data}, ->
  helper.checkLogin()
casper.thenOpen dataUrl, {method: 'POST', data: data1}, ->
casper.thenOpen 'https://ads.epom.com/account/epom-market-analytics/results.do?_dc=1416585965781&page=1&start=0&limit=50', ->
  content = this.getPageContent()
  parsed_content = JSON.parse content
  total = parsed_content.total
  data =
    impressions: str_parser.toInt parsed_content.data[total - 1].impressions
    requests: str_parser.toInt parsed_content.data[total - 1].impressions
    clicks: str_parser.toInt parsed_content.data[total - 1].clicks
    ctr: (str_parser.toFloat(parsed_content.data[total - 1].ctr) / 100.0).toFixed(5)
    revenue: str_parser.toFloat parsed_content.data[total - 1].revenue
    cpm: str_parser.toFloat parsed_content.data[total - 1].ecpm
    currency: 'USD'
  helper.returnData data

casper.run()