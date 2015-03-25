casper_helper = require './casper.helper'

casper = casper_helper.casper
helper = casper_helper.helper
#useful during development
#different messages
#casper.enableDebug()
casper.options.timeout = 70000
casper.options.waitTimeout = 50000
params = helper.params
start_date = params.start_date.format 'M/D/YYYY'
end_date = params.end_date.format 'M/D/YYYY'

casper.start 'https://publishers.kontera.com/', ->
  this.fill 'form#sign_in_form',
    email: params.username
    password: params.password
  , true

casper.then ->
  helper.checkLogin()

casper.waitForSelector "#subtab_detailed", ->
  ref = @evaluate ->
    document.getElementById('subtab_detailed').href
  casper.thenOpen ref

casper.waitForUrl /show/, ->
  @evaluate ->
    elem = document.getElementById('reports_data')
    elem.parentNode.removeChild(elem)
  this.fillSelectors 'form#report_form',
    '#start_date': start_date
    '#end_date': end_date
    'input[name="report"]': 'calendar_timeframe'
  , true

casper.waitForSelector "#reports_data", ->
  get_totals = (number) =>
    this.fetchText(".totals_line > td:nth-child(#{number})").trim()

  get_detailed = (row, col) =>
    this.fetchText("tr.network_line:nth-child(#{row}) > td:nth-child(#{col})").trim()

  #get website from select options, because in table website url may be shortened
  get_website = (row)=>
    tr_id = this.getElementAttribute("tr.network_line:nth-child(#{row})", 'id').replace('tr_','')
    this.fetchText("option[value=\"#{tr_id}\"]")

  row = 1
  detailed = []
  while casper.exists "tr.network_line:nth-child(#{row})"
    detailed.push
      website: get_website(row)
      requests: get_detailed row, 2
      impressions: get_detailed row, 2
      clicks: get_detailed row, 3
      ctr: get_detailed row, 4
      revenue: get_detailed row, 5
      cpm: get_detailed row, 6
      currency: "USD"
    row++

  data =
    requests: get_totals 2
    impressions: get_totals 2
    clicks: get_totals 3
    ctr: get_totals 4
    revenue: get_totals 5
    cpm: get_totals 6
    currency: "USD"
    detailed: detailed

  helper.returnData data

casper.run()