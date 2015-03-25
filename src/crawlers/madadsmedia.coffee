base = require './base'
str_parser = require './string_parser'
class Crawler extends base.Base

  loginURL: 'https://madadsmedia.com/login/'

  timezone: 'America/New_York'
  onlyDaily: true
  @website: false

  init:->
    @timezonePrepare()
    @loginForm =
      email: @username
      password: @password

  process : (err, resp, body, cb) ->
    sd = @start_date.format 'MM/DD/YYYY'
    ed = @start_date.format 'MM/DD/YYYY'
    @reportURL = "https://madadsmedia.com/csv-report/?start_date=#{sd}&end_date=#{ed}&ad_size=0&site="
    @request @reportURL, (err, resp, body) =>
      @csv.parse body, (err, data) =>
        #report = {}
        #report.detailed = []
        for record in data[1..]         
         try
           reportData = 
            currency: 'USD'
            website: record[1]
            impressions: str_parser.toInt record[2]
            cpm: parseFloat(record[3]) || 0
            revenue: parseFloat(record[4]) || 0           
         catch e
           reportData =
              revenue: 0
              cpm: 0
              impressions: 0
              website: ' '
              currency: "USD"
        console.log reportData
        cb reportData

module.exports =
  Crawler: Crawler
