casper_helper = require './casper.helper'

casper = casper_helper.casper
helper = casper_helper.helper
#useful during development
#different messages
#casper.enableDebug()
params = helper.params
start_date = params.start_date.format 'YYYY-MM-DD'
end_date = params.end_date.format 'YYYY-MM-DD'

casper.start 'https://pubops.evolvemediacorp.com/login', ->
  this.fill 'form',
    'auth[email]': params.username
    'auth[password]': params.password
  , true

casper.then ->
  helper.checkLogin()

casper.waitForSelector 'form#filter_form', ->
  this.fill 'form#filter_form',
    'filter[start_date]' : start_date
    'filter[end_date]' : end_date
  , true

casper.waitForUrl /evolvemediacorp/, ->
  if !casper.exists("tr.total") and this.fetchText(".report-data > h2:nth-child(3)") is "No data."
    helper.returnData helper.emptyData()
  else
    get = (number) =>
      this.fetchText "tr.total td:nth-of-type(#{number})"
    data =
      requests: get 2
      impressions: get 2
      clicks: get 3
      revenue: get 4
      cpm: get 5
      currency: "USD"
    helper.returnData data


casper.run()

###
All revenue reflected in your earnings report are ESTIMATES ONLY until final revenue has been fully reconciled.
Due to the complexity of our campaigns and billing, final revenue figures are not reconciled
until on or around the 15th business day of the following month.
Please note that there are many factors that can affect final earnings such as over/under delivery,
the nature and type of ad units or overall media sold, 3rd party reporting discrepancies,
in-flight campaign adjustments and, human error.
Please reach out to your Publisher Services Manager if you have any questions on mid-month report generation. ###
