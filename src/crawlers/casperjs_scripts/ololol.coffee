casper_helper = require './casper.helper'
str_parser = require './../string_parser'

x = require('casper').selectXPath

casper = casper_helper.casper
helper = casper_helper.helper

#casper.enableDebug()
params = helper.params
start_date = params.start_date.format 'DD/MM/YYYY'
end_date = params.end_date.format 'DD/MM/YYYY'


casper.start 'http://www.myswitchads.com/ui/login', ->
  @fillSelectors 'form.sw-login-form',
    'input[name="username"]' : params.username
    'input[name="password"]' : params.password
  , true

casper.then ->
  helper.checkLogin()

casper.then ->
  @open "https://www.myswitchads.com/ui/website-report"  

casper.then ->
  @sendKeys x("//*[@id='period_start']"), start_date, reset: true
  @sendKeys x("//*[@id='period_end']"), end_date, reset: true
  @click x("//*[@id='submit-form']")

casper.then ->
  @waitForSelector '#stats_tbody', ->
    data =
      requests: str_parser.toInt(@fetchText('#impressions-0'))
      impressions: str_parser.toInt(@fetchText('#non_remnant_impressions-0'))
      fill_rate: str_parser.toFloat(@getElementAttribute('#non_remnant_fill-0', 'data-original-title'))  / 100
      revenue: str_parser.toFloat(@getElementAttribute('#non_remnant_revenue-0', 'data-original-title'))
      currency: 'USD'
      cpm: str_parser.toFloat(@fetchText '#non_remnant_ecpm-0')
    helper.returnData data

casper.run()