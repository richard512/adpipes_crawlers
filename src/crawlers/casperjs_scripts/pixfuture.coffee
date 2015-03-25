casper_helper = require './casper.helper'
moment = require 'moment-timezone'

casper = casper_helper.casper
helper = casper_helper.helper

#useful during development pixfuture
#different messages
casper.options.timeout = 150000
casper.options.waitTimeout = 50000
content = undefined
#casper.enableDebug()
params = helper.params
start_date = params.start_date.format 'YYYY-MM-DD'
end_date = params.end_date.format 'YYYY-MM-DD'
daysAgoStart =->
  1 + Math.floor (new Date - moment(start_date).endOf('day')) / 24 / 60 / 60 / 1000
daysAgoEnd = ->
  1 + Math.floor (new Date - moment(end_date).endOf('day')) / 24 / 60 / 60 / 1000
casper.start 'https://beta.portal.pixfuture.net/login', ->
  this.fill 'form',
    _username: params.username
    _password: params.password
  , false
  this.click '.btn'

casper.then ->
  helper.checkLogin()

casper.waitForUrl /dashboard/, ->
casper.thenOpen 'https://beta.portal.pixfuture.net/reporting/', ->
casper.then ->
  first = daysAgoStart()
  second = daysAgoEnd()
  content = this.evaluate (first, second)->
    dataAjax = "{\"start_date\": first, \"end_date\": second}"
    dataAjax = dataAjax.replace /first/g, first
    dataAjax = dataAjax.replace /second/g, second
    console.log dataAjax.toString()
    return  $.ajax { url: 'https://beta.portal.pixfuture.net/api/report/daily', async:false, type: 'post', data:dataAjax}
  , first, second
casper.then ->
  content1 =  JSON.parse content.responseText
  data =
    currency:content1.ReportOutput.reportBody.ReportColumns[1].summary
    revenue:content1.ReportOutput.reportBody.ReportColumns[3].summary
    impressions:content1.ReportOutput.reportBody.ReportColumns[2].summary
    requests:content1.ReportOutput.reportBody.ReportColumns[2].summary
    cpm:content1.ReportOutput.reportBody.ReportColumns[4].summary
    json: content1.ReportOutput.reportBody.ReportData
  helper.returnData data
casper.run()
