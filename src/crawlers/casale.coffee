base = require './base'
str_parser = require './string_parser'

class Crawler extends base.Base

  loginURL: 'https://system.indexexchange.com/login'
  home: "https://system.indexexchange.com/publisher?tabSiteManager.x=1&subTabStats.x=1&siteID="
  home2: 'https://system.indexexchange.com/publisher'
  timezone: 'America/New_York'        #timezone probably depends on the user's location settings
  onlyDaily: true
  @website: false

  init: () ->
    @reportData =
      impressions: 0
      requests: 0
      cpm: 0
      revenue: 0
      currency: 'USD'

    @timezonePrepare()
    @startDateStr = @start_date.format 'YYYY-MM-DD'
    @endDateStr = @end_date.format 'YYYY-MM-DD'
    @loginForm =
      signIn: @username
      loaded: '1'

  process: (err, resp, body, cb) ->
    @request @home, {method: 'GET'}, (err, resp, body) =>
      $ = @cheerio.load(body)
      return unless @checkLogin $
      form = {}
      adFormatIDs = []
      $('input').each (i, obj) ->
        if $(this).attr('type') == 'hidden'
          name = $(this).attr('name')
          form[name] = $(this).attr('value')
          adFormatIDs.push name.substr(0, 3) if name.indexOf('AdUnits') isnt -1
      form.adFormatIDs = adFormatIDs.toString()
      form.months = "01,02,03,04,05,06,07,08,09,10,11,12"
      startYear = +@startDateStr.substr(0, 4)
      endYear = +@endDateStr.substr(0, 4)
      requestCount = endYear - startYear
      for year in [startYear..endYear]
        form.year = year
        @request @home2, {method: 'POST', form: form}, (err, resp, body) =>
          @extract @cheerio.load(body), cb, err, resp
          requestCount--
          if requestCount < 0
            cb @reportData

  extract: ($, cb, err, resp) ->
    startDate = @startDateStr
    endDate = @endDateStr
    reportData = @reportData
    $('#revenueStatsTable .dataRow').each (i, obj)->
      date = $(this).children(0).text()
      if startDate <= date <= endDate
        reportData.impressions += str_parser.toInt($(this).children(1).text())
        defaultImpressions = str_parser.toInt($(this).children(2).text())
        reportData.requests += defaultImpressions + reportData.impressions
        reportData.cpm += str_parser.toFloat($(this).children(4).text())
        reportData.revenue += str_parser.toFloat($(this).children(5).text())
      true


module.exports =
  Crawler: Crawler