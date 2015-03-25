console.log 'sdsdsdsdsd'
casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper

params = helper.params
#casper.enableDebug()

casper.start 'https://my.yieldmanager.com/', ->
  this.evaluate ( (username, password) => 
      document.querySelector('#username').value = username
      document.querySelector('#password').value = password
      #document.querySelector('input[value="Login"]').click()
  ), params.username,params.password
  this.click('input[value="Login"]')

casper.thenOpen "https://my.yieldmanager.com/tab.php?tab_id=1&inc=11", ->
  this.waitForSelector "#submit_report", () =>  
    this.evaluate ((slc_ind,metrics) => 
        document.querySelector('#quick_date').selectedIndex = slc_ind
        document.querySelector('#metricsOption').value = metrics
    ), 13,'all'

casper.then ->
  start_date = params.start_date.format 'MM/DD/YYYY'
  end_date = params.end_date.format 'MM/DD/YYYY'
  this.evaluate ((start_date, end_date) => 
      document.querySelector('#start_date').value = start_date
      document.querySelector('#end_date').value = end_date
      document.querySelector('#start_hour').selectedIndex = 0
      document.querySelector('#end_hour').selectedIndex = 23
  ), start_date,end_date
  this.click('#submit_report')


casper.then ->
  get = (number) =>
    this.fetchText ".total_footer td:nth-child(#{number})"

  #this.waitForSelector "#report_table", () => 
  this.wait 7000, () => 
    jdata = {}
    jdata['click_rate'] = str_parser.toFloat(get(5))
    jdata['conversions_rate'] = str_parser.toFloat(get(6))
    jdata['conversions'] = str_parser.toInt(get(4))
    jdata['net_pub_comp'] = str_parser.toFloat(get(7))
    jdata['roi'] = str_parser.toFloat(get(9))
    impressions = str_parser.toInt(get(2))
    cpm = str_parser.toFloat(get(7))
    clicks = str_parser.toFloat(get(3))
    data = 
      requests: impressions
      impressions: impressions
      revenue: (impressions / 1000 * cpm).toFixed 2
      clicks: clicks
      currency: 'USD'
      cpm: cpm
      json:jdata
    helper.returnData data
casper.run()
