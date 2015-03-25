casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper

#useful during development
#different messages
#casper.enableDebug()
casper.options.timeout = 100000
params = helper.params
curDate =  new Date().getTime()
start_date = params.start_date.format "MM^DD^YYYY"
end_date = params.end_date.format "MM^DD^YYYY"


casper.start 'http://app.qadabra.com/users/sign_in', ->
  @fillSelectors 'form.new_user',
    'input[name="user[email]"]' : params.username
    'input[name="user[password]"]' : params.password
  , true

casper.then ->
  helper.checkLogin()

casper.then ->
  @open "http://app.qadabra.com/reports"  

casper.then ->
  @open "http://app.qadabra.com/reports/search?utf8=%E2%9C%93&[start_date]=07%2F08%2F2014&[end_date]=21%2F03%2F2015&[adtag_active]=&[adtag]=&commit=Go"  

casper.then ->

  get = (number) =>
    text = this.evaluate ((number)=>
      $('#reports tfoot tr td').eq(number).text() ), number

  this.wait 5000,() ->
    console.log get(2)
    jdata = {}

    data = 
      #requests: 0
      impressions: str_parser.toInt(get(2))
      revenue: str_parser.toFloat(get(6))
      clicks: str_parser.toInt(get(3))
      currency: 'USD'
      ctr: str_parser.toFloat(get(4))
      json:jdata
    helper.returnData data

casper.run()