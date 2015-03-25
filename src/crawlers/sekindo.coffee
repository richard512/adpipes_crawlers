base = require './base'
str_parser = require './string_parser'

class Crawler extends base.Base

  loginURL: 'https://www.sekindo.com/account/login.php'
  home: 'https://www.sekindo.com/publisher/mySpaces.php'

  timezone: 'America/New_York'
  onlyDaily: true
  @website: false

  init: () ->
    @timezonePrepare()
    @loginForm =
      userName: @username
      password: @password
      __submit_login_check: 1
    @headers['Cookie'] = 'viewer_start_date='+@start_date.format 'YYYY-MM-DD'+';'  
    @headers['Cookie'] +='viewer_end_date='+@end_date.format 'YYYY-MM-DD'+';'
    @headers['Cookie'] +='viewer_type=user;'
    

  extract: ($, cb, err, resp) ->
    data = {}
    first_column = ($ '.totalStatsTable td').eq(1).text().split('/')
    impr = str_parser.toInt(first_column[0])
    data['unq'] = str_parser.toInt(first_column[1])
    data['leads'] = str_parser.toInt(($ '.totalStatsTable td').eq(3).text())
    data['conv_rate(%)'] = str_parser.toFloat(($ '.totalStatsTable td').eq(5).text())
    reportData =
      impressions : impr
      requests : impr
      cpm : str_parser.toFloat(($ '.totalStatsTable td').eq(6).text())
      cpc : str_parser.toFloat(($ '.totalStatsTable td').eq(7).text())
      revenue: str_parser.toFloat(($ '.totalStatsTable td').eq(8).text())
      clicks : str_parser.toInt(($ '.totalStatsTable td').eq(2).text())
      ctr : str_parser.toFloat(($ '.totalStatsTable td').eq(4).text()).toFixed 2
      currency: 'USD'
      json : data
    cb reportData

module.exports =
  Crawler: Crawler
