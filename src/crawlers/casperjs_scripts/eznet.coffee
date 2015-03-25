casper_helper = require './casper.helper'

casper = casper_helper.casper
helper = casper_helper.helper
#useful during development
#different messages
#casper.enableDebug()
params = helper.params
start_date = params.start_date.format 'YYYY-MM-DD'
end_date = params.end_date.format 'YYYY-MM-DD'
requestUrl = 'http://ai.ezmob.com/reports/'
formData =
  dateRange:start_date + " - " + end_date
  groupBy:"date"
  execute:"Generate+report"
  export_file:""
casper.start 'http://ai.ezmob.com/auth/login', ->
  this.fill 'form#login-form',
    identity: params.username
    password: params.password
  , true
casper.waitForUrl /publishers/, ->
casper.thenOpen requestUrl, {method: "POST", data: formData}, ->
  get = (number) =>
    value = (this.fetchText "#report_table1 td:nth-of-type(#{number})").replace /,|\$|%/g, ''
  error = this.fetchText '#page-content > p:nth-child(5)'
  if error
    impressions = 0
    clicks = 0
    ctr = 0
    cpm = 0
    cpc = 0
    revenue = 0
  else
    impressions = get 2
    clicks = get 3
    ctr = get 4
    cpm = get 5
    cpc = get 6
    revenue = get 7

  data =
    impressions: impressions
    requests: impressions
    clicks: clicks
    ctr: ctr
    cpm: cpm
    cpc: cpc
    revenue: revenue
    currency: 'USD'

  helper.returnData data

casper.run()
