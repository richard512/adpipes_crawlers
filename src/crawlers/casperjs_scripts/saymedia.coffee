casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper

params = helper.params
#casper.enableDebug()

casper.start 'https://dash.saymedia.com/reports/', ->
  this.evaluate ( (username, password) =>
    document.querySelector('#email').value = username
    document.querySelector('#password').value = password
  ), params.username, params.password
  this.click('button[value="Sign In"]')

casper.then ->
  helper.checkLogin()
  this.waitForSelector "#kpi-earnings .kpi-value", () =>
    start_date = params.start_date.format 'MM/DD/YYYY'
    end_date = params.end_date.format 'MM/DD/YYYY'
    this.evaluate ((start_date, end_date) =>
      document.querySelector('#datefilter-custom').setAttribute 'checked', true
      document.querySelector('#daterange-custom-start').value = start_date
      document.querySelector('#daterange-custom-end').value = end_date
    ), start_date, end_date
    this.click('#daterange-apply')

casper.then ->
  this.wait 6000, () =>
    requests = str_parser.toInt(this.fetchText "#kpi-impressions .kpi-value")
    impressions = requests
    cpm = str_parser.toFloat(this.fetchText "#kpi-avgcpm .kpi-value")
    data =
      requests: requests
      impressions: impressions
      revenue: str_parser.toFloat(this.fetchText("#kpi-earnings .kpi-value").replace('(undefined)',''))
      fill_rate: str_parser.toFloat(this.fetchText "#kpi-avgfill .kpi-value")
      cpm: cpm
      currency: 'USD'
    helper.returnData data
casper.run()
