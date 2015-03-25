casper_helper = require './casper.helper'

casper = casper_helper.casper
helper = casper_helper.helper
params = helper.params
start_date = params.start_date.format 'YYYY-MM-DD'
end_date   = params.end_date.format 'YYYY-MM-DD'
console.log "Dates inside crawler script:"
console.log params.start_date.format 'YYYY-MM-DD HH:mm'
console.log params.end_date.format 'YYYY-MM-DD HH:mm'

#timestamp in milliseconds
ts   = params.end_date.valueOf()
#generate reports url using time parameters
url="https://management.kixer.com/stats/query/day.json?format=transpose&metrics=revenue%2Cviews%2Cvcpm%2Cclicks%2Cvctr&start=#{start_date}&end=#{end_date}&_=#{ts}"

casper.start 'https://management.kixer.com/users/login', ->
  this.fill 'form',
    "data[User][email]": params.username
    "data[User][password]": params.password
  , true
casper.then ->
  helper.checkLogin()
  this.thenOpen url, ->
    try
      json_data=JSON.parse this.getHTML('pre')
      #last column is column with total values
      total_column=json_data[json_data.length-1]
    catch error
      total_column=[0,0,0,0,0,0]
    revenue  = total_column[1]
    requests = impressions = total_column[2]
    cpm      = total_column[3]
    clicks   = total_column[4]
    ctr      = total_column[5]

    data =
      currency: 'USD'
      requests: requests
      impressions: impressions
      revenue: revenue
      cpm: cpm
      ctr: ctr
      clicks: clicks
    helper.returnData data

casper.run()
