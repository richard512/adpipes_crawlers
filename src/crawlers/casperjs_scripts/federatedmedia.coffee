casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper
params = helper.params
#casper.enableDebug()

casper.options.timeout = 50000

casper.start 'https://publishers.federatedmedia.net/', ->
  this.evaluate ( (username, password) => 
      document.querySelector('#user_name').value = username
      document.querySelector('#user_password').value = password
  ), params.username,params.password
  this.click('.input-submit-save')

casper.then ->
  helper.checkLogin()

casper.thenOpen "https://publishers.federatedmedia.net/reports/campaigns",->
    this.evaluate () => 
      $('#select_dates_by_range').prop('checked', true)

    sd = params.start_date.format "YYYY-MM-DD"
    ed = params.end_date.format "YYYY-MM-DD"

    this.evaluate ((sd,ed) => 
      $('#start-date').val(sd)
      $('#end-date').val(ed)
    ),sd,ed
    this.click('#campaigns-view')

    
casper.then ->
  get = (number) =>
    text = this.evaluate ((number)=>
      $('.total-row td').eq(number).html()
      ), number
    text = text.split('<br>')[0]

  this.waitForSelector '.total-row',=>
    cpm = str_parser.toFloat get 1
    revenue = str_parser.toFloat get 3
    if cpm 
      requests = parseInt(1000*revenue/cpm)
    else 
      requests = 0
    data =   
      cpm: cpm
      revenue: revenue
      currency: 'USD'
      requests: requests
    helper.returnData data
  
casper.run()
