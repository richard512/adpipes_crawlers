casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper

params = helper.params
#casper.enableDebug()

casper.options.timeout = 50000

casper.start 'https://www.stackadapt.com/users/sign_in', ->
  this.evaluate ( (username, password) => 
      document.querySelector('#user_email').value = username
      document.querySelector('#user_password').value = password
  ), params.username,params.password
  this.click('input[value="Login"]')

casper.then ->
  helper.checkLogin()

casper.waitForUrl /dashboard/, ->
  casper.thenOpen "https://www.stackadapt.com/stats/data?type=publisher&id=455", {method : "GET"}, =>
    content = this.getPageContent()
    j_answer = JSON.parse content
    sd = params.start_date.format "YYYY-MM-DD"
    for i in [0..j_answer.body.length-1]
      if j_answer.body[i].date == sd
        data =   
          impressions: j_answer.body[i].imp
          clicks: j_answer.body[i].click
          fill_rate: j_answer.body[i].fill
          ctr: j_answer.body[i].ctr
          cpc: j_answer.body[i].rcpc
          cpm: j_answer.body[i].rcpm
          revenue: j_answer.body[i].revenue
          currency: 'USD'
          json: j_answer.body[i]
        helper.returnData data
        break
casper.run()
