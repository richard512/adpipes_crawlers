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

casper.start params.loginURL, ->
  this.fill 'form#login-form',
    username: params.username
    password: params.password
  , true
  console.log 'start *** ' + params.crawlerName

authCompleted = ->
  url = casper.getCurrentUrl()
  return url.match(/report/) or url.match(/error/)

casper.waitFor authCompleted, ->
  helper.checkLogin()

#todo: select all metrics, if possible

casper.then ->
  start_date = params.start_date.format 'MM/DD/YYYY'
  end_date = params.end_date.format 'MM/DD/YYYY'
  report_interval = 'cumulative'
  report_timezone = 'EST5EDT'
  this.evaluate ((start_date, end_date, report_interval, report_timezone)->
      document.querySelector('#report-range').value = 'custom'
      document.querySelector('#report-custom-start-date').value = start_date
      document.querySelector('#report-custom-end-date').value = end_date
      document.querySelector('#report-interval').value = report_interval
      document.querySelector('#report-timezone').value = report_timezone
      #document.getElementById('include-dimension-ids').checked = true # if checked, id and site name are in separate columns
      document.getElementById('grouping-option-0').checked = true #placement group
      #document.getElementById('grouping-option-1').checked = true #placement
    )
  , start_date, end_date, report_interval, report_timezone

casper.thenClick '#run-report'

isReportReady = ->
  casper.exists('td.clicks') or casper.exists('div.feedback')

casper.waitFor isReportReady, ->
  if this.fetchText('div.feedback') == "No records found"
    helper.returnData helper.emptyData()
    return

  get = (row, col) =>
    this.fetchText(".grid-scroll-table > tbody:nth-child(2) > tr:nth-child(#{row}) > td:nth-child(#{col})").trim()

  row = 1
  detailed = []
  while casper.exists ".grid-scroll-table > tbody:nth-child(2) > tr:nth-child(#{row})"
    detailed.push
      currency: "USD"
      website: get row, 1  # "placement group" column  in report table, consist of id and site name
      revenue: str_parser.toFloat get row, 5
      requests: str_parser.toInt get row, 2
      impressions: str_parser.toInt get row, 2
      clicks: str_parser.toInt get row, 3
      json:
        "Total Conversions": get row, 4
        "Publisher RPM": get row, 6
    row++

  impressions = str_parser.toInt(this.fetchText('tfoot td.imps_total'))
  requests = impressions
  data =
    currency: 'USD'
    impressions: impressions
    requests: requests
    revenue: str_parser.toFloat(this.fetchText('tfoot td.publisher_revenue'))
    clicks: str_parser.toInt(this.fetchText('tfoot td.clicks'))
    detailed: detailed
    json:
      "Total Conversions": this.fetchText('tfoot td.total_convs')
      "Publisher RPM": this.fetchText('tfoot td.publisher_rpm')
  helper.returnData data

casper.run()