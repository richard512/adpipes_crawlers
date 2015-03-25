base = require './base'
str_parser = require './string_parser'
_ = require 'lodash'

class Crawler extends base.Base
  home: 'http://mefeedia.com/solutions'
  loginURL: 'http://mefeedia.com/solutions/login'
  loginForm: {login: 1}
  @website: false

  extract: ($, cb) ->
    return unless @checkLogin $
    @timezonePrepare()
    startDateStr = @start_date.format 'YYYY-MM-DD'
    endDateStr = @end_date.format 'YYYY-MM-DD'
    url = @home + '/' + $('.export').attr('href').replace('/4/', "/#{startDateStr}%7C#{endDateStr}/")
    console.log url
    @request url, (err, resp, body) =>
      @csv.parse body, (err, data) =>
        result =
          'currency': 'USD'
          'detailed': []
        if data.length > 1
          data = data[1..]
          for record of data
            if data[record]?
              result.detailed.push
                ad_tag: data[record][1]
                revenue: str_parser.toFloat data[record][3]
                requests: str_parser.toInt data[record][2]
                impressions: str_parser.toInt data[record][2]
                currency: 'USD'
          @sumDetailed result
          cb result
        else
          _.merge result, {revenue: 0, requests: 0, impressions: 0}
          cb result


module.exports =
  Crawler: Crawler
