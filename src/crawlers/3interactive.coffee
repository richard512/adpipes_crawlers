base = require './base'
str_parser = require './string_parser'

class Crawler extends base.Base
  loginURL : 'https://target.zedo.com/servlet/LoginServlet'
  dataURL : 'https://target.zedo.com/Main?reporttype=performance&reportname=Quick_Performance_Report'

  timezone: 'America/New_York'
  onlyDaily: true
  @website: false

  init: ->
    @timezonePrepare()
    @loginForm =
      rem: 0
      form : 'login'
      fromSupport : 'no'
      fromEmail : 'false'
      uid : @username
      pwd : @password

  login : (form = {}, cb) ->
    [form, cb] = [{}, form] if typeof form is 'function'
    @request @loginURL, {method : 'POST', form : @merge(@loginForm, form)}, cb


  process : (err, resp, body, cb) ->
    params =
      method : 'POST'
      form :
        step: 'create'
        event_key: 'performance_rpt'
        mobilereport: 'off'
        scheduler: 'NO'
        report: 3
        tperiod: 'summary'
        prevTimePeriod: 'summary'
        timePeriod: 'summary'
        i18n_startDate: @start_date.format 'MM/DD/YYYY'
        startDate: @start_date.format 'MM/DD/YYYY'
        i18n_endDate: @end_date.format 'MM/DD/YYYY'
        endDate: @end_date.format 'MM/DD/YYYY'
        publisher:-1
        dimension:-1
        showImpsDelivered: 'on'
        showClicksDelivered: 'on'
        showClickRate: 'on'
        nwtId:305
    @request @dataURL, params, (err, resp, body) =>
      @extract @cheerio.load(body), cb, err, resp


  extract : ($, cb, err, resp) ->
    return unless @checkLogin $
    try
      impressions = str_parser.toFloat ($ '.listTypeOne td').eq(1).text()
      reportData =
        impressions : impressions
        requests : impressions
        #They served at a fixed cpm for 3 USD.
        cpm : 3
        revenue: ((impressions / 1000) * 3).toFixed 2
        clicks : str_parser.toInt ($ '.listTypeOne td').eq(2).text()
        ctr : str_parser.toFloat ($ '.listTypeOne td').eq(3).text()
        currency: 'USD'      
    catch e
      reportData =
        revenue: 0
        requests: 0
        impressions: 0
        currency: "USD"
    cb reportData

module.exports = Crawler : Crawler