base = require './base'
str_parser = require './string_parser'

class Crawler extends base.Base
  timezone: 'GMT'
  onlyDaily: true
  loginURL: 'https://my.smaato.com/selfservice/login.do'
  updateReportConfigUrl: 'https://my.smaato.com/selfservice/updateReportConfiguration.do'
  dataURL: 'https://my.smaato.com/selfservice/generateReportTable.do'
  home: ''
  @website: false

  init: () ->
    @timezonePrepare()
    @loginForm =
      j_username: @username
      j_password: @password

  process: (err, resp, body, cb) ->
    params =
      reportType: "REVENUE"
      allAdSpaces: true
      reportPeriod: "CUSTOM"
      reportStart: @start_date.format ('YYYY-MM-DD')
      reportEnd: @end_date.format ('YYYY-MM-DD')
      firstRevenueFacet: "REVENUE"
      secondRevenueFacet: "NONE"
      userReportSubType: "UNIQUE_USERS"

    @request @updateReportConfigUrl, {method: 'POST', json: true, body: params}, (err, resp, body) =>
      console.log err if err
      @request @dataURL, (err, resp, body) =>
        console.log err if err
        report = @emptyData()
        report.detailed = []
        try
          for record in JSON.parse(body).aaData
            report.detailed.push
              impressions: record[4]
              revenue: record[9]
              requests: record[1]
              fill_rate: record[3]
              clicks: record[5]
              ctr: record[6]
              cpc: record[7]
              cpm: record[8]
              currency: 'USD'
              json:
                served_ads: record[2]
                date: record[0]
        catch e
          reportData =
            revenue: 0
            requests: 0
            impressions: 0
            currency: "USD"
          return
        cb report

#  Why are there discrepancies between "Served Ads" and "Impressions"?
# A positive response from the Smaato advertising optimization platform usually ends up in a served ad.
# A served ad typically implies a banner impression on the device.
# In reality, the number of impressions is a bit lower than the number of served ads.
# One reason for this may be that the end user stopped the application before the banner was fully loaded.
# Thus the number of served ads and impressions can vary.

module.exports =
  Crawler: Crawler