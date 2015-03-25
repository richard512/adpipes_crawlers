casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper

#useful during development
#different messages
#casper.enableDebug()
params = helper.params
start_date = params.start_date.format 'MM/DD/YYYY'
end_date = params.end_date.format 'MM/DD/YYYY'
formParams =
  from_date:start_date
  to_date:end_date
  report_by:"days"
  submit:"Show"
dataUrl = "https://partner.pricegrabber.com/partner.php/performance_summary/"
casper.start 'https://partner.pricegrabber.com/mss_main.php', ->
  this.fill 'form',
    un: params.username
    p: params.password
  , true

casper.then ->
  helper.checkLogin()

casper.waitForUrl /direct_buy/,->
casper.thenOpen dataUrl, {method:"POST", data: formParams}, ->
  get = (number) =>
    this.getHTML "table.grid>tbody>tr:last-child>td:nth-of-type(#{number})"
  try
    data =
      impressions: str_parser.toInt(get 8)
      requests: str_parser.toInt(get 8)
      clicks: str_parser.toInt(get 9)
      ctr: str_parser.toFloat(get 10)
      cpm: str_parser.toFloat(get 11)
      revenue: str_parser.toFloat(get 12)
      currency:'USD'
  catch error
    data =
      impressions: 0
      requests: 0
      clicks: 0
      ctr: 0
      cpm: 0
      revenue: 0
      currency:'USD'

  helper.returnData data

casper.run()