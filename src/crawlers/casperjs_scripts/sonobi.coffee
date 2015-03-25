casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper

#useful during development
#different messages
#casper.enableDebug()
casper.options.timeout = 2000000
params = helper.params
start_date = params.start_date.format "YYYY-MM-DD"
end_date = params.start_date.format "YYYY-MM-DD"
queryDataRes = {}
querySiteData =
  cm:"site.list"
  key:"adv627"
  code:"2b83d849e5"

queryUrl = 'http://sonobi.com/public/'

queryData =
  cm:"report.request"
  key:"adv627"
  code:"2b83d849e5"
  _report:""
  _report_type:"publisher_plugin"
  _report_origin:"publisher_reporting"
  _range:"custom"
  _range_start_date:start_date
  _range_end_date:end_date
fillData = (parsed_content, callback) ->
  if parsed_content.error_code == 33
    callback()
  else
    try
      clicks = parsed_content.package.result[0]._click_count
    catch error
      clicks = 0
    try
      impressions = parsed_content.package.result[0]._impression_count
    catch error
      impressions = 0
    requests = impressions
    try
      revenue = parsed_content.package.result[0]._revenue
    catch error
      revenue = 0
    try
      cpm = parsed_content.package.result[0]._ecpm
    catch error
      cpm = 0

    data =
      clicks: str_parser.toInt clicks
      impressions: str_parser.toInt impressions
      requests: str_parser.toInt requests
      currency:'USD'
      revenue: str_parser.toFloat revenue
      cpm: str_parser.toFloat cpm
    helper.returnData data

tryToFillData = (pointer) ->
  pointer.open(queryUrl, {method:"POST", data:queryDataRes}).then ->
    pageContent = this.getPageContent()
    parsed_content = JSON.parse pageContent
    fillData parsed_content, ->
      tryToFillData pointer


casper.start 'http://sonobi.com/welcome/login.php', ->
  this.fill 'form',
    _username: params.username
    _password: params.password
  , true
casper.thenOpen "http://sonobi.com/page.php?p=dashboard/advanced", ->
casper.thenOpen queryUrl, {method:"POST", data:querySiteData}, ->
  pageContent = this.getPageContent()
  parsed_content = JSON.parse pageContent
  siteIds = []
  for entry in parsed_content.package
    siteIds[siteIds.length] = entry._id
  perem = siteIds.join ','
  queryData._report = '{"_siteid":' + '"' + perem + '"' + ',"groupby":"day","row_per":"_date,_siteid","columns":"_impression_count,_click_count,_revenue,_ecpm,_siteid_name,_siteid,_date","tz_offset":"UTC"}'
casper.thenOpen queryUrl, {method:"POST", data:queryData}, ->
  pageContent = this.getPageContent()
  parsed_content = JSON.parse pageContent
  reportId = parsed_content.package._reportid
  queryDataRes =
    cm:"report.get"
    key:"adv627"
    code:"2b83d849e5"
    _reportid:reportId
    _wait:"true"
  tryToFillData (this)


casper.run()

