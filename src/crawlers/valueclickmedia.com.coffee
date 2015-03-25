base = require './base'
str_parser = require './string_parser'
xml2js = require 'xml2js'
moment = require 'moment-range'
_ = require 'lodash'
Promise = require 'bluebird'

class Crawler extends base.Base
  @website: false
  timezone: 'America/Los_Angeles'
  onlyDaily: true

  loginURL: 'https://admin.valueclickmedia.com/corp/login/submit'
  home: 'https://pub.valueclickmedia.com/reports/snapshot'
  revenueXML: 'https://pub.valueclickmedia.com/reports/earnings/doughnut_chart?start_date={start_date}&end_date={end_date}&site_id={site_id}&media_type_id=&country_id=0'
  impressionsXML: 'https://pub.valueclickmedia.com/reports/defaults/grid?month={month}&site_id={site_id}&media_type_id=&site_default_id=&country_id=0'

  init: ->
    #calculate @start_date && @end_date for adv network's timezone
    @timezonePrepare()
    @loginForm =
      user_name: @username

  processSingleDay: (day)->

  process: (err, resp, body, cb) ->
    @request @home, (err, resp, body) =>
      $ = @cheerio.load body
      
      sites = []
      report = {}
      report.detailed = []
      $('#search-site_id option')[1..].each (i, el) ->
        tempSite = {}
        tempSite.name = $(el).text().trim()
        tempSite.id = $(el).val()
        sites.push tempSite if tempSite.id > 0

      Promise.each sites, (site) =>
        revenueXML = @revenueXML.replace /\{start_date\}/, @start_date.format 'YYYY-MM-DD'
        revenueXML = revenueXML.replace /\{end_date\}/, @end_date.format 'YYYY-MM-DD'
        revenueXML = revenueXML.replace /\{site_id\}/, site.id
        tempReport = {}
        @requestAsync(revenueXML).spread (response, body) =>
          return unless @checkLogin(@cheerio.load(body))
          xml2js.parseString body, (err, data) ->
            amounts = if data.chart.set then (+set.$.value for set in data.chart.set) else []
            tempReport.revenue = amounts.reduce((a, b) ->
              a + b
            , 0)

          #let's calculate unique months
          range = moment().range @start_date, @end_date
          months = []
          range.by 'days', (moment) ->
            months.push moment.format 'YYYY-MM'
          months = _.uniq months
          #end of uniq months
          urls = (@impressionsXML.replace(/\{site_id\}/, site.id).replace /\{month\}/, month for month in months)
          promises = (@requestAsync url for url in urls)
          Promise.all(promises).then (responses) =>
            bodies = (response[0].body for response in responses)
            rows = []
            for body in bodies
              xml2js.parseString body, (err, data) =>
                rows = rows.concat data.rows.row
            tempReport['currency'] = 'USD'
            tempReport['requests'] = 0
            tempReport['impressions'] = 0
            range.by 'days', (moment) ->
              date = moment.format 'YYYY-MM-DD'
              row = rows.filter (row) ->
                row.$.id is date
              values = row[0].cell
              tempReport['website'] = site.name
              tempReport['requests'] += +values[3]
              tempReport['impressions'] += +values[1]
            report.detailed.push tempReport
      .then ->
        cb report

module.exports =
  Crawler: Crawler
