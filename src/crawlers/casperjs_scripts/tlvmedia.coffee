casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper

#useful during development
#different messages
#casper.enableDebug()
casper.options.timeout = 60000
params = helper.params
start_date = params.start_date.format 'MM/DD/YYYY'
end_date = params.end_date.format 'MM/DD/YYYY'
casper.start 'http://pub.tlvmedia.com/login', ->
  this.fill 'form#login_form',
    login_email: params.username
    login_password: params.password
  , true

casper.then ->
  helper.checkLogin()

casper.thenOpen "http://pub.tlvmedia.com/publisher_ws/get_publisher_report?start=#{start_date}&end=#{end_date}&section=0&size=0&country=0&groupby=revdate&type=&groupby2=revdate&_search=false&nd=1416564828664&rows=250&page=1&sidx=revdate&sord=asc",->
  content = this.getHTML('body')
  parsed_content = JSON.parse content
  data =
    impressions: str_parser.toInt parsed_content.userdata.impressions
    clicks: str_parser.toInt parsed_content.userdata.clicks
    revenue: str_parser.toFloat parsed_content.userdata.rev
    cpm: str_parser.toFloat parsed_content.userdata.ecpm
    requests: str_parser.toInt parsed_content.userdata.impressions
    ctr: str_parser.toFloat parsed_content.userdata.ctr
    currency:'USD'
  helper.returnData data

casper.run()