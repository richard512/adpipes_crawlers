casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper
#useful during development
#different messages
#casper.enableDebug()
params = helper.params
casper.start 'https://gumgum.com/login', ->
  this.fill 'form#login-form',
    email: params.username
    password: params.password
  , true

casper.then ->
  helper.checkLogin()

casper.waitForUrl /reports/, ->
  casper.thenOpen 'https://gumgum.com/p/reports', ->

  casper.then ->
    start_date = params.start_date.format 'YYYY-MM-DD'
    end_date = params.end_date.format 'YYYY-MM-DD'
    this.open "https://gumgum.com/p/reports/widget/table/metric/earnings/start/#{start_date}/end/#{end_date}/zones/ALL/format/get.json"
  casper.then ->
    content = this.getPageContent()
    parsed_content = JSON.parse content
    data =
      currency: 'USD'
      impressions: str_parser.toInt parsed_content.totals.ad_views
      requests: str_parser.toInt parsed_content.totals.ad_views
      revenue: str_parser.toFloat parsed_content.totals.ad_revenue
      cpm: str_parser.toFloat parsed_content.totals.cpm
    helper.returnData data

casper.run()