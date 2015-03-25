base = require './base'
str_parser = require './string_parser'

class Crawler extends base.Base
  home : 'https://www.adblade.com/'
  loginURL : 'https://www.adblade.com/control/login/'
  timezone: 'GMT'
  @website: false

  login : (form = {}, cb) ->
    [form, cb] = [{}, form] if typeof form is 'function'
    @request @loginURL, {method : @loginMethod, form : @merge(@merge(@loginForm, email : @username, password : @password), form)}, cb
    @timezonePrepare()

  process: (err, resp, body, cb) ->
    startDate = @start_date.format 'YYYY-MM-DD'
    endDate = @end_date.format 'YYYY-MM-DD'
    dataURL = "https://www.adblade.com/pub/appstatsreport?startDate=#{startDate}&endDate=#{endDate}&isContentNet=0&status=1"
    return unless @checkLogin @cheerio.load body
    @request dataURL, (err, resp, body) =>
      @csv.parse body, (err, response) =>
        for record in response[1...-1]
          try
            reportData = 
              currency: 'USD'
              ad_tag: record[2]
              clicks: record[3]
              impressions: record[4]
              cpm: str_parser.toFloat record[5]
              revenue: str_parser.toFloat record[6]
          catch e
            reportData =
              revenue: 0
              cpm: 0
              impressions: 0
              clicks: 0
              ad_tag: 0
              currency: "USD"  
          #console.log reportData
          cb reportData

module.exports =
  Crawler: Crawler
