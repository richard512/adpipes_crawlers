casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper
#useful during development
#different messages
#casper.enableDebug()
params = helper.params
start_date = params.start_date.format 'YYYY-MM-DD'
end_date = params.end_date.format 'YYYY-MM-DD'
casper.start 'https://publishers.chitika.com/login', ->
  this.fill 'form#login',
    login: params.username
    password: params.password
  , true
casper.waitForUrl /dashboard/
casper.thenOpen 'https://publishers.chitika.com/reports/advanced'
casper.thenOpen "https://publishers.chitika.com/reports/advanced?date=custom&groupBy=date&start_date=#{start_date}&end_date=#{end_date}&groupName=&ki_frsct=48518110f1c7bfed922f342cbc200771", ->
  get = (number) =>
    this.fetchText "#adv_report_totals tfoot th:nth-of-type(#{number})"
  impressions = str_parser.toInt(get(2))
  data =
    impressions: impressions
    requests: impressions
    clicks:  str_parser.toInt(get(3))
    ctr: (str_parser.toFloat(get(4))/100.0).toFixed(5)
    cpm: str_parser.toFloat(get(5))
    revenue: str_parser.toFloat(get(6))
    currency:"USD"

  helper.returnData data
casper.run()
