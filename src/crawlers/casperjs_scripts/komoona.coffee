casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper
#useful during development
#different messages
#casper.enableDebug()
params = helper.params

casper.start 'http://komoona.com', ->
  this.fill 'form#frm-login',
    username: params.username
    password: params.password
  , true

casper.then ->
  helper.checkLogin()

id = null
casper.thenOpen 'https://www.komoona.com/reports/income', ->
  id = this.evaluate ->
    siteid
casper.then ->
  start_date = params.start_date.format 'YYYY-MM-DD'
  end_date = params.end_date.format 'YYYY-MM-DD'
  this.open "https://www.komoona.com/stat/cpm/tags_table?accountid=#{id}&iframe=tags-report-iframe&from=#{start_date}&to=#{end_date}"

casper.then ->
  get = (number) =>
    value = this.fetchText "#summery-chart .google-visualization-table-tr-even td:nth-of-type(#{number})"
    if value == '' then 0 else value

  data =
    requests: get(2)
    impressions: get(3)
    fill_rate: (str_parser.toFloat(get(4))) / 100
    revenue: str_parser.toFloatWithComma(get(5))
    cpm:  get(6)
    currency: 'USD'
  helper.returnData data
casper.run()