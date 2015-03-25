casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper

#useful during development
#different messages
#casper.enableDebug()
casper.options.timeout = 50000
params = helper.params
start_date = params.start_date.format 'YYYY-MM-DD'
end_date = params.end_date.format 'YYYY-MM-DD'

casper.start 'https://hub.skimlinks.com/login', ->
  this.fill 'form',
    username: params.username
    password: params.password
  , true

casper.then ->
  casper.wait 2000, -> #todo: to improve reliability of login checking, but should be replaced with something more reliable
    helper.checkLogin()

casper.thenOpen "https://hub.skimlinks.com/proxy/publisher/reportdomains?startDate=#{start_date}&endDate=#{end_date}&product=showcases%2Cskimlinks%2Cskimwords&responseLimit=100&orderBy=totalCommission%7Cdescending", ->
  parsed_content = JSON.parse this.getPageContent()
  if parsed_content.skimlinksAccount.error
    throw Error JSON.stringify(parsed_content.skimlinksAccount.error)
  domains = parsed_content.skimlinksAccount.domains #if no data domains is empty object {}
  detailed = []
  for key,value of domains
    detailed.push
      website: value.domainName #there is domainID field also
      clicks: value.clicks
      currency: value.currency
      revenue: str_parser.toFloat(value.totalCommission) / 100 # /100 because totalCommission in cents
      cpc: value.ecpc

  casper.thenOpen "https://hub.skimlinks.com/proxy/publisher/reporttotals?startDate=#{start_date}&endDate=#{end_date}&product=showcases%2Cskimlinks%2Cskimwords", ->
    parsed_content = JSON.parse this.getPageContent()
    if parsed_content.skimlinksAccount.error
      throw Error JSON.stringify(parsed_content.skimlinksAccount.error)
    totals = parsed_content.skimlinksAccount.totals
    data =
      clicks: totals.affiliated_clicks
      currency: totals.currency
      revenue: str_parser.toFloat(totals.commissions) / 100
      cpc: totals.ecpc
      detailed: detailed
    helper.returnData data


casper.run()