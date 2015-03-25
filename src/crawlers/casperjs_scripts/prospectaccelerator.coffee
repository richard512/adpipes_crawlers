casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper

#useful during development
#different messages
#casper.enableDebug()
params = helper.params
casper.options.timeout = 70000
casper.options.waitTimeout = 70000
start_date = params.start_date.format 'YYYY-MM-DD'
end_date = params.end_date.format 'YYYY-MM-DD'

casper.start "https://pub.prospectaccelerator.com/signin", ->
  this.fill 'form#new_user',
    "user[email]": params.username
    "user[password]": params.password
  , true

authCompleted =->
  casper.exists("a[href=\"/reporting\"]") or casper.getCurrentUrl().match(/error/)

casper.waitFor authCompleted, ->
  helper.checkLogin()

casper.thenOpen 'http://pub.prospectaccelerator.com/reporting'

casper.waitForSelector ".channel", ->
  evaluated = this.evaluate ((start_date, end_date) ->
      try
        $('#time_period').val("custom").change();
        $('#start_date').val(start_date).change();
        $('#end_date').val(end_date).change();
      catch error
        return error.toString()
      return 'ok'
    )
  , start_date, end_date
  throw new Error(evaluated) if evaluated isnt 'ok'

casper.thenClick ".channel"

casper.thenClick ".tag"

casper.thenClick ".domain"

casper.thenClick "button.btn-success"

casper.waitForSelector "td.reporting-totals:nth-child(2)", ->
  get = (row, col) =>
    this.fetchText(".table > tbody:nth-child(2) > tr:nth-child(#{row}) > td:nth-child(#{col})").trim()

  if get(1, 4) is '' and get(1, 5) is ''
    helper.returnData helper.emptyData()
    return

  row = 1
  rows = []
  while casper.exists ".table > tbody:nth-child(2) > tr:nth-child(#{row})"
    rows.push
      currency: "USD"
      custom_channel: get row, 1
      website: get row, 2
      ad_tag: get row, 3
      revenue: str_parser.toFloat get row, 5
      requests: str_parser.toInt get row, 4
      impressions: str_parser.toInt get row, 4
      clicks: str_parser.toInt get row, 6
      ctr: (str_parser.toFloat get row, 8) / 100
      json: {RPM: get(row, 9), Conversion: get(row, 7)}
    row++

  totals = rows.pop()
  delete totals.custom_channel
  delete totals.website
  delete totals.ad_tag
  if rows.length > 0
    totals.detailed = rows
  helper.returnData totals

casper.run()

