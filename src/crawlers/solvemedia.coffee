base = require './base'
str_parser = require './string_parser'

class Crawler extends base.Base
  onlyDaily: true
  timezone: 'EST'
  home: 'https://portal.solvemedia.com/portal'
  indexURL: 'https://portal.solvemedia.com/portal/login'
  loginURL: 'https://portal.solvemedia.com/portal/login-1'
  reportURL: 'https://portal.solvemedia.com/portal/pub/dash-pub-report-data'
  @website: true

  init: ->
    @timezonePrepare()

  login: (cb) ->
    @request @indexURL, (err, resp, body) =>
      $ = @cheerio.load body
      form = 
        email: @username
        pass: @password
        check: $("[name='check']").val()
        next: ''
        submit: ''
      @request @loginURL, {method: 'POST', form: form}, cb

  extract: ($, cb, err, resp) ->
    queryString = 
      acc: resp.request.uri.query.slice 4
      fmt: 'csv'
      bucket: 86400
      #start: '2013-08-01'
      start: @start_date.format 'YYYY-MM-DD'
      end: @end_date.format 'YYYY-MM-DD'    
    @request @reportURL, qs: queryString, (err, resp, body) =>
      console.log err if err
      @csv.parse body, (err, data) ->
        report = 
          detailed: []
          currency: 'USD'
        website = ''
        for record in data
          tempReport = {}
          if ~record[0].indexOf 'Publication: '
            website = record[0].slice 13
          if (isNaN record[0]) and (Date.parse record[0])            
            try              
              reportData =
                revenue: record[10]
                currency: record[11]
                website: website
                json:
                  date: record[0]
                  served: record[1]
                  solved: record[2]
                  failed: record[3]
                  cancelled: record[4]
                  expired: record[5]
                  no_script: record[6]
                  image: record[7]
                  audio: record[8]
                  not_solved: record[9]
            catch e
              reportData =
                revenue: 0
                currency: 0
                website: 'no'
                json: ' '
                                 
        console.log reportData   
        cb reportData

module.exports =
  Crawler: Crawler  
