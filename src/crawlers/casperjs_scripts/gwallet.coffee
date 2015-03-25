casper_helper = require './casper.helper'

casper = casper_helper.casper
helper = casper_helper.helper
params = helper.params

#timestamp in milliseconds
ts_start = params.start_date.valueOf()
ts_end = params.end_date.valueOf()

url = "https://rui.gwallet.com/report/publisherreport?customFrom=#{ts_start}&customTo=#{ts_end}&reportPeriod=CUSTOM&reportType=ACTIVITY_REVENUE"

casper.start 'https://rui.gwallet.com/login', ->
  @fillSelectors 'form',
    'input[name="j_username"]' : params.username
    'input[name="j_password"]' : params.password
  , true  

casper.then ->
  helper.checkLogin()

casper.thenOpen url, ->
  get = (number) =>
    this.fetchText "table.ro-tbl tr:nth-of-type(4) > td:nth-of-type(#{number})"
  requests = get(2)
  impressions = requests
  data =
    impressions: impressions
    requests: requests
    clicks: get 3
    ctr: get 4
    cpm: get 6
    revenue: get 7
    currency: "USD"
  helper.returnData data
casper.run()