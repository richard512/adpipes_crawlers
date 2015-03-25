base = require './base'
str_parser = require './string_parser'
google = require 'googleapis'

config = (require '../config').GOOGLE_OAUTH
oauth2Client = new google.auth.OAuth2 config.CLIENT_ID, config.CLIENT_SECRET, config.REDIRECT_URI

#Adexchange providing data on daily bases on "America/Los_Angeles" timezone (PDT)
#List of metrics - https://developers.google.com/ad-exchange/seller-rest/metrics-dimensions
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

      adexchange = google.adexchangeseller 'v2.0'
      #useful dimensions - 'AD_FORMAT_CODE', 'AD_FORMAT_NAME', 'DOMAIN_NAME'
      dimensions = ['AD_CLIENT_ID', 'AD_TAG_CODE', 'AD_TAG_NAME',
                    'CUSTOM_CHANNEL_CODE', 'CUSTOM_CHANNEL_ID', 'CUSTOM_CHANNEL_NAME']
      metrics = [
        'AD_REQUESTS', 'AD_REQUESTS_COVERAGE', 'AD_REQUESTS_CTR', 'AD_REQUESTS_RPM', 'CLICKS', 'COST_PER_CLICK',
        'EARNINGS', 'INDIVIDUAL_AD_IMPRESSIONS', 'INDIVIDUAL_AD_IMPRESSIONS_CTR',
        'INDIVIDUAL_AD_IMPRESSIONS_RPM',
        'MATCHED_AD_REQUESTS', 'MATCHED_AD_REQUESTS_CTR', 'MATCHED_AD_REQUESTS_RPM', 'MATCHED_AD_REQUESTS',
        'MATCHED_AD_REQUESTS_CTR', 'MATCHED_AD_REQUESTS_RPM'
      ]

      try
        adexchange.accounts.list {}, (err, response)=>
          console.log err if err

          accounts = response.items
          #we have only one account per login/pass
          #because we connect publisher to our AdExchange with our link to register
          account = accounts[0]
          adexchange.accounts.reports.generate
            accountId: account.id
            startDate: @start_date.format 'YYYY-MM-DD'
            endDate: @end_date.format 'YYYY-MM-DD'
            dimension: dimensions
            metric: metrics,
            (err, response) =>
              console.log err if err
              if err && err.errors && err.errors[0].reason = 'partialReportData'
                return cb @emptyData()
              reverseMetrics = {}
              reverseMetrics[header.name] = i for header, i in response.headers
              get = (metric, row)->
                if (!row)
                  return response.totals[reverseMetrics[metric]]
                row[reverseMetrics[metric]]

              impressions = Math.round get('AD_REQUESTS') * get('AD_REQUESTS_COVERAGE')
              json = {}
              json[header.name] = get(header.name) for header in response.headers

              data =
                revenue: get 'EARNINGS'
                impressions: impressions
                requests: get 'AD_REQUESTS'
                fill_rate: get 'AD_REQUESTS_COVERAGE'
                ctr: get 'AD_REQUESTS_CTR'
                clicks: get 'CLICKS'
                cpc: get 'COST_PER_CLICK'
                cpm: get 'AD_REQUESTS_RPM'
                currency: response.headers[reverseMetrics['COST_PER_CLICK']].currency
                json: json
              rows = []
              for rowResponse in response.rows
                impressions = Math.round get('AD_REQUESTS', rowResponse) * get('AD_REQUESTS_COVERAGE', rowResponse)
                json = {}
                json[header.name] = get(header.name, rowResponse) for header in response.headers
                row =
                  revenue: get 'EARNINGS', rowResponse
                  impressions: impressions
                  requests: get 'AD_REQUESTS', rowResponse
                  fill_rate: get 'AD_REQUESTS_COVERAGE', rowResponse
                  ctr: get 'AD_REQUESTS_CTR', rowResponse
                  clicks: get 'CLICKS', rowResponse
                  cpc: get 'COST_PER_CLICK', rowResponse
                  cpm: get 'AD_REQUESTS_RPM', rowResponse
                  currency: response.headers[reverseMetrics['COST_PER_CLICK']].currency
                  ad_tag: get 'AD_TAG_CODE', rowResponse
                  custom_channel: get 'CUSTOM_CHANNEL_ID', rowResponse
                  json: json
                rows.push row
              data['detailed'] = rows
              cb data
      catch e
        return

module.exports =
  Crawler: Crawler
