casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper

#useful during development
#different messages
#casper.enableDebug()
params = helper.params
casper.options.timeout = 200000
casper.options.waitTimeout = 100000

startDate = params.start_date.format 'YYYY-MM-DD'
endDate = params.end_date.format 'YYYY-MM-DD'
report_url = "http://oboxmedia.com/a/reporting/view?startDate=#{startDate}&endDate=#{endDate}&groupBy=domain-banner&formActions%5Brefresh%5D=refresh"

casper.start 'http://oboxmedia.com/a/login', ->
  this.fill 'form.login',
    username: params.username
    password: params.password
  , true

casper.then ->
  helper.checkLogin()

casper.thenOpen report_url

casper.waitForSelector 'td.totals', ->
  get = (row, col) =>
    this.fetchText(".resultsTable > tbody:nth-child(2) > tr:nth-child(#{row}) > td:nth-child(#{col})").trim()
  row = 1
  detailed = []
  while casper.exists ".resultsTable > tbody:nth-child(2) > tr:nth-child(#{row})"
    if !casper.exists ".resultsTable > tbody:nth-child(2) > tr:nth-child(#{row + 1})"
      break #because last line is totals
    impr = str_parser.toInt get row, 3
    detailed.push
      currency: "USD"
      website: get row, 1
      ad_tag: get row, 2 # this parametr named "ad format" in oboxmedia
      requests:  impr
      impressions: impr
      revenue: str_parser.toFloat  get row, 4
      cpm:  str_parser.toFloat get row, 5
    row++

  total_impressions = @evaluate ->
    $('td.imp').last().text()
  total_revenue = @evaluate ->
    $('td.rev').last().text()
  total_cpm = @evaluate ->
    $('td.cpm').last().text()

  impressions = str_parser.toInt total_impressions
  data =
    impressions: impressions
    requests: impressions
    revenue: str_parser.toFloat total_revenue
    cpm: str_parser.toFloat total_cpm
    currency: 'USD'
    detailed: detailed
  helper.returnData data

casper.run()