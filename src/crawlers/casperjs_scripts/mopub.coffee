casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper
params = helper.params
#casper.enableDebug()

casper.options.timeout = 50000


casper.start 'https://app.mopub.com/account/login/', ->
  this.evaluate ( (username, password) => 
      document.querySelector('#id_username').value = username
      document.querySelector('#id_password').value = password
  ), params.username,params.password
  this.click('#login-submit')

casper.then ->
  helper.checkLogin()
  this.waitForSelector "#datepicker-button", () =>
    sd = params.start_date.format "MM/DD/YYYY"
    url = "https://app.mopub.com/dashboard/?r=1&s=#{sd}"
    casper.thenOpen url,{method:'GET'}, ->
      this.waitForSelector "#datepicker-button", () => 
        revenue     = this.fetchText "#revenue-tab-total"
        impressions = this.fetchText "#impressions-tab-total"
        cpm         = this.fetchText "#ecpm-tab-total"
        ctr         = this.fetchText "#ctr-tab-total"
        fill_rate   = this.fetchText "#total_fill_rate-tab-total"
        data = 
          impressions: impressions
          requests: impressions
          revenue: revenue
          currency: 'USD'
          cpm: cpm
          ctr: ctr
          fill_rate: fill_rate
        helper.returnData data

casper.run()
