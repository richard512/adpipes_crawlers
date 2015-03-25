casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper
params = helper.params
#casper.enableDebug()

casper.options.timeout = 50000



casper.start 'https://publisher.adknowledge.com/user/login', ->
  this.evaluate ( (username, password) => 
      document.querySelector('#email').value = username
      document.querySelector('#password').value = password
  ), params.username,params.password
  this.click('#submit')

casper.then ->
  helper.checkLogin()
  this.waitForSelector "#product5Options",=>
    this.thenOpen "https://publisher.adknowledge.com/reports/miva",=>
      this.waitForSelector "#presetReport",=>
        sd = params.start_date.format "YYYY-MM-DD"
        ed = params.end_date.format "YYYY-MM-DD"

        this.evaluate ( (start_date,end_date) =>
          $('#presetDateRange').val("custom").change()
          $("#customDateStart").val(start_date)
          $("#customDateEnd").val(end_date)
        ), sd,ed 
        this.click('#module-reporting-options-submit')
    

casper.then ->

  get = (number) =>
    text = this.evaluate ((number)=>
      $('.aggregate .value').eq(number).text() ), number

  this.wait 5000,() ->
    data = 
      impressions: get 1
      revenue: get 3
      clicks: get 2
      currency: 'USD'
    helper.returnData data


casper.run()
