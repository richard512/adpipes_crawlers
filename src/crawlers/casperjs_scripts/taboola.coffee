casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper

params = helper.params
#casper.enableDebug()

casper.options.timeout = 50000



casper.start 'https://backstage.taboola.com/backstage/login', ->
  this.evaluate ( (username, password) => 
      document.querySelector('#j_username').value = username
      document.querySelector('#j_password').value = password
  ), params.username,params.password
  this.click('#login')

casper.then ->
  helper.checkLogin()
  this.waitForSelector "#addQueryFilterBtn", () =>
    start_date = params.start_date.format 'MM/DD/YYYY'
    #start_date = '11/15/2014'//to test paid period
    end_date = params.end_date.format 'MM/DD/YYYY'
    this.evaluate ( (start_date, end_date) => 
      document.querySelector('#dp1').value = start_date
      document.querySelector('#dp2').value = end_date
    ), start_date,end_date
    this.click('input[value="Select"]')

casper.then ->

  get = (number) =>
    text = this.evaluate ((number)=>
      $('.taboola-tbl tfoot tr td').eq(number).text() ), number

  this.wait 5000,() ->
    jdata = {}
    jdata['cpc'] = str_parser.toFloat(get(6))
    jdata['rpm'] = str_parser.toFloat(get(7))
    jdata['%with ads'] = str_parser.toFloat(get(2))

    data = 
      requests: str_parser.toInt(get(1))
      impressions: str_parser.toInt(get(3))
      revenue: str_parser.toFloat(get(8))
      clicks: str_parser.toInt(get(5))
      currency: 'USD'
      ctr: str_parser.toFloat(get(4))
      json:jdata
    helper.returnData data


casper.run()
