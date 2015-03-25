casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper
params = helper.params
start_date = params.start_date.format 'YYYY-MM-DD'
end_date   = params.end_date.format 'YYYY-MM-DD'

firstMonth = params.start_date.month()
firstYear  = params.start_date.year()
firstDay   = params.start_date.date()
 
url="http://www.bannerflux.com/user.php?action=ads_statistic_ecpm&size=11&month=#{firstMonth+1}&year=#{firstYear}"

casper.start 'http://www.bannerflux.com/', ->
  this.fill 'form',
    username: params.username
    password: params.password
  , true
casper.then ->
  helper.checkLogin()
  this.thenOpen url, ->
    get = (column,cell) =>
      this.getHTML("table.common_table td:nth-of-type(#{column}) table tr:nth-of-type(#{cell}) td.cell_embosed4")
    requests    = get(1,firstDay+2)
    impressions = requests
    revenue     = get(2,firstDay+2)
    cpm         = get(3,firstDay+2)
    data =
      currency: 'USD'
      requests: requests
      impressions: impressions
      revenue: revenue
      cpm: cpm
    helper.returnData data

casper.run()
