#docs - http://docs.openx.com/api/index.html#api_authentication.html
#today request
#dataJSON: 'http://us-market.openx.com/ox/4.0/report/run?report_format=json&start_date=0end_date=0&report=site_sum'

base = require './base'
str_parser = require './string_parser'
moment = require 'moment-timezone'

class Crawler extends base.Base
  timezone: 'America/Los_Angeles'
  onlyDaily: true

  loginURL: 'https://sso.openx.com/login/process'
  dataJSON: 'http://us-market.openx.com/ox/4.0/report/run?report_format=json&start_date={start_days_ago}&end_date={end_days_ago}&report=site_sum'
  loginURL2: 'http://us-market.openx.com/ox/4.0/session'
  @website: true

  init: () ->
    @loginForm =
      email: @username
    #calculate @start_date && @end_date for adv network's timezone
    @timezonePrepare()

  process: (err, resp, body, cb) ->
    dataJSON = @dataJSON.replace /{start_days_ago}/, @daysAgo(@start_date)
    dataJSON = dataJSON.replace /{end_days_ago}/, @daysAgo(@end_date)
    @request dataJSON, (err, resp, body) =>
      try
        json = JSON.parse resp.body
      catch err
        if body.indexOf("<!DOCTYPE") isnt -1
          if @checkLogin(@cheerio.load(body))
            throw err    #if not auth failed, throw err again
          else
            return
      @extract json, cb, err, resp

  run: (cb) ->
    @login (err, resp, body) =>
      @headers['oauth-assist'] = true
      @request @loginURL2, {method: 'PUT', form: {oob: true, oauth_callback_url: 'http://us-market.openx.com/#ready?'}}, (err, resp, body) =>
        linkWithToken = body
        @request linkWithToken, method: 'POST', (err, resp, body) =>
          authVerifier = resp.headers['location']
          authVerifier = authVerifier.replace '#ready?', 'ox/4.0/ready?'
          @request authVerifier, (err, resp, body) =>
            @process err, resp, body, cb

  extract: (json, cb, err, resp) ->
    data = {}
    data[value.column_name] = value.summary for value in json.ReportOutput.reportBody.ReportColumns
    reportData =
      impressions: data['billable_impressions']
      cpm: data['publisher_billable_eRPM'] # the value shown as eCPM
      revenue: data['publisher_revenue']
      requests: data['requests']
      fill_rate: (str_parser.toFloat data['fill_rate']) / 100
      currency: data['currency']

    detailed = []
    for site_report in json.ReportOutput.reportBody.ReportData
      detailed.push
        website: site_report[0]  #  site_report[1] is site id
        currency: site_report[2]
        requests: site_report[3]
        impressions: site_report[4]
        revenue: site_report[5]
        cpm: site_report[6]
        fill_rate: (str_parser.toFloat site_report[7]) / 100
    reportData.detailed = detailed

    cb reportData

  daysAgo: (date) ->
    #so if endOf day is a little bin in future that mean that is current day, and we will have "1+-1=0". So 0 is today
    #If endOf day is already passed, we will have at least 1. That will mean 1 day ago.
    1 + Math.floor (new Date - moment(date).endOf('day')) / 24 / 60 / 60 / 1000

module.exports =
  Crawler: Crawler
