casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper
#useful during development
#different messages
casper.options.timeout = 100000
casper.options.pageSettings.loadPlugins = false
params = helper.params

start_date = params.start_date.format 'MM/DD/YYYY'
end_date = params.end_date.format 'MM/DD/YYYY'
dataUrl = "https://control.media.net/reports/getreportsjqplot"

casper.start 'http://www.media.net', ->
  this.fill 'form#userloginform',
    username: params.username
    password: params.password
  , true

step2 = ->
  data =
    from: start_date
    to: end_date
    DataStatus: 1
    ReportGroupType: 1

  casper.thenOpen dataUrl, {method: 'POST', data: data}, ->
    json = JSON.parse this.getPageContent()
    if json.length is 0
      data = helper.emptyData()
    else
      json = json[0]
      data =
        requests: json.CustomerImpressions
        impressions: json.CustomerImpressions
        revenue: json.CustomerRevenue
        currency: 'USD'
    helper.returnData data

#workaround for strange situation https://github.com/n1k0/casperjs/issues/1089
casper.waitForUrl /home/, step2, step2
casper.options.onTimeout = step2


casper.run()