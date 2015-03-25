base = require './base'
str_parser = require './string_parser'

#to get token use link
#https://publishers.criteo.com/exportguide.aspx
class Crawler extends base.Base
  @website: true
  timezone: 'GMT'
  onlyDaily: true
  loginURL: 'https://publishers.criteo.com/'
  tokenURL: 'https://publishers.criteo.com/exportguide.aspx'
  init: ->
    @loginForm =
      '__EVENTTARGET': 'ctl00_MainContent_ctlLogin_ctlLogin_LoginBtn'
      '__EVENTARGUMENT': ''
      'ctl00_MainContent_ctlLogin_ctlLogin_UserName': @username
      'ctl00_MainContent_ctlLogin_ctlLogin_Password': @password
    
    #calculate @start_date && @end_date for adv network's timezone
    @timezonePrepare()


  process: (cb) ->
    start_date = @start_date.format 'YYYY-MM-DD'
    end_date = @end_date.format 'YYYY-MM-DD'
    url = "http://publishers.criteo.com/statsexport.aspx?apitoken=#{@token}&begindate=#{start_date}&enddate=#{end_date}"
    currency = 'USD'
    @request url, (err, resp, body) =>
      @csv.parse body, {delimiter: ';'}, (err, data) =>
        if data.length > 1
          data = data[1..]
          rows = []
          for record of data
            if data[record]?
              current = data[record]
              rows.push
                currency: currency
                website: current[1]
                ad_tag: current[3]
                revenue: str_parser.toFloat current[10]
                requests: str_parser.toInt current[5]
                impressions: str_parser.toInt current[6]
                ctr: str_parser.toFloat current[8]
                cpm: str_parser.toFloat current[9]
                fill_rate: (str_parser.toFloat current[7]) / 100
          advData =
            currency: currency
            detailed: rows
          @sumDetailed advData
          cb advData

  run: (cb) ->
    
    @process(cb)

module.exports =
  Crawler: Crawler