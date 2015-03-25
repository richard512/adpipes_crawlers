casper_helper = require './casper.helper'

casper = casper_helper.casper
helper = casper_helper.helper
#useful during development
#different messages
#casper.enableDebug()
params = helper.params
start_date = params.start_date.format 'MM/DD/YYYY'
end_date = params.end_date.format 'MM/DD/YYYY'
queryUrl = "https://reports.advertising.com/dispatch?token=185182.-1.185182.-1.-1.-1.4.0&rt=2&dfilter=custom&&crossover=0&defout=0&cmps=0"
qyeryData =
  formType: "CustomDate"
  CustomDateFrom: start_date
  CustomDateTo: end_date
  Apply:"Apply"
  validated:"1"
casper.start 'https://reports.advertising.com/login', ->
  this.fill 'form',
    username: params.username
    password: params.password
  , true

casper.then ->
  helper.checkLogin()

casper.thenOpen queryUrl, {method:'POST', data:qyeryData}, ->
  this.click 'input'

casper.then ->
  get = (number) =>
    value = this.fetchText("tr[bgcolor= '#AFC5E4'] >  td:nth-of-type(#{number})").trim()
  impressions = get 2
  if !impressions or impressions == ''
    data =
      impressions: 0
      request: 0
      revenue: 0
      currency: 'USD'
    helper.returnData data

  else
    data =
      impressions: get 2
      requests: get 2
      clicks: get 4
      revenue: get 6
      cpm: get 7
      currency:'USD'
    helper.returnData data

casper.run()