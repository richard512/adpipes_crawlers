base = require './base'
str_parser = require './string_parser'

class Crawler extends base.Base
  loginURL : 'http://console.mediashakers.com/index/sign-in'
  IdURL : 'http://console.mediashakers.com/ver/report/get-id'
  GetURL : 'http://console.mediashakers.com/ver/report/get'
  GetVersionURL : 'http://console.mediashakers.com/'

  timezone: 'America/New_York'

  onlyDaily: true
  @website: false

  init: ->
    @timezonePrepare()

  process : (err, resp, body, cb) ->
    @request @GetVersionURL, (err, resp, body) =>
      $ = @cheerio.load(body)
      version = ($ '.version').text()
      @IdURL = @IdURL.replace /ver/, version
      @GetURL = @GetURL.replace /ver/, version

      params =
        method : 'POST'
        form :
          'report[category]': 'publisher_login'
          'report[type]': 'analytics'
          'report[format]': 'standard'
          'report[range]': 'custom'
          'report[start_date]': @start_date.format 'MM/DD/YYYY'
          'report[end_date]': @end_date.format 'MM/DD/YYYY'
          'report[interval]': 'cumulative'
          'report[metrics]': ["imps_total","imps_sold","clicks","click_thru_pct","total_convs","convs_rate","convs_per_mm","publisher_revenue","publisher_rpm"]
          'report[run_type]': 'run_now'
          'report[email_format]': 'excel'
          'report[pre_send_now_email_addresses]': 'affiliate@nster.com'
          'report[schedule_when]': 'daily'
          'report[schedule_format]': 'excel'
          'report[name]': 'Report'
          'report[timezone]': 'UTC'

      @request @IdURL, params, (err, resp, body) =>
        json = JSON.parse body
        params =
          method : 'POST'
          form :
              id: json.report_id
              columns : ["imps_total","imps_sold","clicks","click_thru_pct","total_convs","convs_rate","convs_per_mm","publisher_revenue","publisher_rpm"]
              show_as_pivot:false
              report_type:'publisher_analytics'

        @request @GetURL, params, (err, resp, body) =>
          result_json = JSON.parse body
          if result_json.html == ''
            console.log 'response is empty, sending new request...'
            @process err, resp, body, cb
          else
            @extract @cheerio.load(result_json.html), cb, err, resp

  extract : ($, cb, err, resp) ->
    data = {}
    data['imps_sold'] = str_parser.toInt(($ '.imps_sold').text())
    data['publisher_rpm($)'] = str_parser.toFloat(($ '.publisher_rpm').text())
    data['total_conversions'] = str_parser.toInt(($ '.total_convs').text())
    data['conversions_rate(%)'] = str_parser.toFloat(($ '.convs_rate').text())
    reportData =
      impressions : str_parser.toInt(($ '.imps_total').text())
      requests : str_parser.toInt(($ '.imps_total').text())
      cpm : str_parser.toFloat(($ '.convs_per_mm').text())
      revenue: str_parser.toFloat(($ '.publisher_revenue').text())
      clicks : str_parser.toInt(($ '.clicks').text())
      ctr : str_parser.toFloat(($ '.click_thru_pct').text())
      currency: 'USD'
      json : data
    cb reportData

module.exports = Crawler : Crawler
