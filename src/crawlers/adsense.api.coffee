base = require './base'
str_parser = require './string_parser'
google = require 'googleapis'

config = (require '../config').GOOGLE_OAUTH
oauth2Client = new google.auth.OAuth2 config.CLIENT_ID, config.CLIENT_SECRET, config.REDIRECT_URI

#Adsense providing data on daily bases on "America/Los_Angeles" timezone (PDT)
class Crawler extends base.Base
  timezone: 'America/Los_Angeles'
  onlyDaily: true
  @website: false

  init: ->
    #calculate @start_date && @end_date for adv network's timezone
    @timezonePrepare()

  run: (cb) ->
    oauth2Client.setCredentials refresh_token: @adNetwork.refresh_token
    oauth2Client.refreshAccessToken (err, tokens) =>
      google.options auth: oauth2Client

      adsense = google.adsense 'v1.4'
      params = ['AD_REQUESTS', 'AD_REQUESTS_COVERAGE', 'AD_REQUESTS_CTR', 'AD_REQUESTS_RPM', 'CLICKS', 'COST_PER_CLICK',
        'EARNINGS', 'INDIVIDUAL_AD_IMPRESSIONS', 'INDIVIDUAL_AD_IMPRESSIONS_CTR', 'INDIVIDUAL_AD_IMPRESSIONS_RPM',
        'MATCHED_AD_REQUESTS', 'MATCHED_AD_REQUESTS_CTR', 'MATCHED_AD_REQUESTS_RPM', 'MATCHED_AD_REQUESTS',
        'MATCHED_AD_REQUESTS_CTR', 'MATCHED_AD_REQUESTS_RPM', 'PAGE_VIEWS', 'PAGE_VIEWS_CTR', 'PAGE_VIEWS_RPM'
      ]
      reverseParams = {}
      reverseParams[param] = i for param, i in params

      adsense.reports.generate
        startDate: @start_date.format 'YYYY-MM-DD'
        endDate: @end_date.format 'YYYY-MM-DD'
        metric: params, (err, response) =>
          console.log err if err
          get = (param) ->
             response.totals[reverseParams[param]] ? 0
          try
            impressions = Math.round  get('AD_REQUESTS') * get('AD_REQUESTS_COVERAGE')
            json = {}
            json[param]= get(param) for param in params
            data =
              revenue: get('EARNINGS')
              impressions: impressions
              requests: get('AD_REQUESTS')
              fill_rate: get('AD_REQUESTS_COVERAGE')
              ctr: get('AD_REQUESTS_CTR')
              clicks: get('CLICKS')
              cpc: get('COST_PER_CLICK')
              cpm: get('AD_REQUESTS_RPM')
              currency: response.headers[reverseParams['COST_PER_CLICK']].currency
              json: json
          catch
            return
          cb data

module.exports =
  Crawler: Crawler
