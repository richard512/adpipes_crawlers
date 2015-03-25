base = require './base'
str_parser = require './string_parser'
_ = require 'lodash'

class Crawler extends base.Base
  timezone: 'Europe/London'
  onlyDaily: true

  home: 'http://www.lijit.com/users/' + @username + '#/ads'
  loginURL: 'https://secure.lijit.com/user/login'
  loginForm: {submit: 1}
  @website: false

  init: ->
    #calculate @start_date && @end_date for adv network's timezone
    @timezonePrepare()

  process: (err, resp, body, cb) ->
    startDate = @start_date.format 'YYYY-MM-DD'
    endDate = @end_date.format 'YYYY-MM-DD'
    url = "http://www.lijit.com/stats/publisherCSV/?startDate=#{startDate}&endDate=#{endDate}&timePeriod=daily&uri=http%3A%2F%2Fwww.lijit.com%2Fusers%2F" + @username
    @request url, (err, resp, body) =>
      return unless @checkLogin(@cheerio.load(body))
      @csv.parse body, (err, response) =>
        data =
          'currency': 'USD'
          'detailed': []
        if response.length <= 2
          _.merge data, {revenue: 0, requests: 0, impressions: 0}
          cb data
        else if response.length > 2
          params = response[0]
          reverseParams = {}
          reverseParams[param] = i for param,i in params
          response = response[1...-1]
          for record of response
            get = (name)->
              response[record][reverseParams[name]]
            try
              data.detailed.push
                ad_tag: get 'Tag Name'
                revenue: str_parser.toFloat(get 'Earnings')
                requests: str_parser.toInt(get 'Requests')
                impressions: str_parser.toInt(get 'Impressions')
                ctr: str_parser.toFloat(get 'CTR')
                cpm: str_parser.toFloat(get 'eCPM')
                fill_rate: (str_parser.toFloat(get 'Fill Rate')) / 100
                currency: 'USD'
            catch e
              reportData =
                revenue: 0
                requests: 0
                impressions: 0
                currency: "USD"
              return
          @sumDetailed data
          cb data

module.exports =
  Crawler: Crawler