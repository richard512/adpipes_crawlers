base = require './base'
str_parser = require './string_parser'

class Crawler extends base.Base

  loginURL: 'https://app.intergi.com/user_session'
  dataURL: 'https://app.intergi.com/publishers2/dashboard/update'
  data2URL: 'https://app.intergi.com/publishers2'

  timezone: 'America/New_York'
  onlyDaily: true
  @website: false

  init: () ->
    @timezonePrepare()
    @loginForm =
      'user_session[email_address]': @username
      'user_session[password]': @password

  process : (err, resp, body, cb) ->
      params =
        method : 'POST'
        form :
          date_range:9
          start_date:@start_date.format 'MM/DD/YYYY'
          end_date:@end_date.format 'MM/DD/YYYY'
      @request @dataURL, params, (err, resp, body) =>
        @request @data2URL, (err, resp, body) =>
          @extract @cheerio.load(body), cb, err, resp

  extract: ($, cb, err, resp) ->
    return unless @checkLogin $
    table = ($ '#totalsTable tr')
    result = table.eq(table.length-1).find('td')
    data = {}
    data['default_impressions'] = str_parser.toInt(result.eq(1).text())
    reportData =
      impressions : str_parser.toInt(result.eq(0).text())
      requests : str_parser.toInt(result.eq(0).text())
      cpm : str_parser.toFloat(result.eq(3).text())
      revenue: str_parser.toFloat(result.eq(2).text())
      currency: 'USD'
      json : data
    cb reportData

module.exports =
  Crawler: Crawler
