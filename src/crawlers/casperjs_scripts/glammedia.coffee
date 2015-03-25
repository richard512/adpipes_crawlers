casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper
params = helper.params
#casper.enableDebug()

casper.options.timeout = 50000

casper.start 'http://insidernew.glam.com/insider_new/Signin', ->
  this.evaluate ( (username, password) => 
      document.querySelector('#username').value = username
      document.querySelector('#password').value = password
  ), params.username,params.password
  this.click('input[alt="Sign In"]')

casper.then ->
  helper.checkLogin()
  sd = params.start_date.format "MM/DD/YYYY"
  ed = params.end_date.format "MM/DD/YYYY"
  s_date = new Date(params.start_date.get('year'),params.start_date.get('month'),params.start_date.get('date'))
  e_date = new Date(params.end_date.get('year'),params.end_date.get('month'),params.end_date.get('date'))
  date_num = Math.floor((e_date-s_date)/(1000*60*60*24));
  if date_num >0
    reportDate = "#{sd}-#{ed}"
  else
    reportDate = "#{sd}"

  formData = 
    reportDate : reportDate
    preset : 0
    calendarOption : ""

  casper.thenOpen "http://insidernew.glam.com/insider_new/YieldReport/showYieldReportHeadingTotals", {method: "POST", data: formData}, =>
    content = this.getPageContent()
    content = content.split('~')
    jdata = {}
    jdata['preliminary_total'] = content[5]
    jdata['rate'] = content[6].split('</body></html>')[0]
    data =   
      requests: content[0].split('<html><head></head><body>')[1]
      impressions: content[1]
      clicks: content[3]
      fill_rate: content[2]
      ctr: content[4]
      currency: 'USD'
      json:jdata
    helper.returnData data
  
casper.run()
