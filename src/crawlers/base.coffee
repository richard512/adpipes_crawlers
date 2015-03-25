moment = require 'moment-timezone'
_ = require 'lodash'
models  = require '../models'
Promise = require 'bluebird'
request = require('request').defaults(jar: true)
requestAsync = Promise.promisify request
str_parser = require './string_parser'

class Base

  #better to override this in child class to be sure you have correct timezone
  timezone: 'EST'

  #if we can request only daily data
  onlyDaily: true

  #override this in  child class to add initialization
  init: ->

  home: null
  loginURL: ''
  loginMethod: 'POST'
  loginForm: {}
  headers:
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36'

  constructor: (@time_type, @adNetwork, @requested_start_date, @requested_end_date, record_id) ->
    @cookieJar = request.jar()
    @username = @adNetwork.username
    @password = @adNetwork.password
    @errorDbId = record_id
    @init()

  #set correct @start_date and @end_date for timezone
  timezonePrepare: ->
    if @time_type == 'remote'
      @start_date = moment.tz @requested_start_date, @timezone
      @end_date = moment.tz @requested_end_date, @timezone
    else if @time_type == 'local'
      @start_date = moment @requested_start_date
      @start_date.tz @timezone
      @end_date = moment @requested_end_date
      @end_date.tz @timezone

      @requested_start_date = moment @requested_start_date
      @requested_end_date = moment @requested_end_date

  request: (url, options = {}, cb) ->
    [options, cb] = [
      {},
      options
    ] if typeof options is 'function'
    request @reverse_merge(options, url: url, jar: @cookieJar, headers: @headers), cb

  #promise
  requestAsync: (url, options = {}) ->
    requestAsync _.merge(options, url: url, jar: @cookieJar, headers: @headers)

  login: (form = {}, cb) ->
    [form, cb] = [
      {},
      form
    ] if typeof form is 'function'
    @request @loginURL, {method: @loginMethod, form: @merge(@merge(@loginForm,
      username: @username, password: @password), form)}, cb

  #override run instead of this
  publicRun: (cb) ->
    @run (data) =>
      if data
        @finish data
      cb data

  run: (cb) ->
    @login (err, resp, body) =>
      @process err, resp, body, cb

  checkLogin: ($)->
    #console.log "Authorization failed for user #{@username}"
    if $("[type=password]").length > 0
      errorData =
        id: @errorDbId
        status: "breaked by login"
        error_id: 3
      models.AdNetworkError.edit errorData
      console.log "Authorization failed for user #{@username}"
      return false
    return true

  process: (err, resp, body, cb) ->
    @request @home, (err, resp, body) =>
      $ = @cheerio.load(body)
      if @checkLogin $
        @extract $, cb, err, resp

  extract: ($, cb, err, resp) ->
    cb $, err, resp

  #for calculated fields
  finish: (data) ->
    json = data['json']
    data['json'] = JSON.stringify(json) if json and (typeof json == 'object' or typeof json == 'array')
    calculatedData =
      requested_start_date: @requested_start_date
      requested_end_date: @requested_end_date
      processing_date: new Date()
      day: @start_date.format 'YYYY-MM-DD'
      interval_type: @detect_interval_type()
      start_date: @start_date.toDate()
      end_date: @end_date.toDate()
      timezone: @timezone
    _.merge data, calculatedData
    #converting to number
    to_int = ['impressions', 'requests', 'clicks']
    to_float = ['revenue', 'fill_rate', 'ctr', 'cpm', 'cpc']
    for key in to_int
      data[key] = str_parser.toInt data[key] if data[key]
    for key in to_float
      data[key] = str_parser.toFloat data[key] if data[key]

    @finish row for row in data['detailed'] if data['detailed']

  emptyData: ->
    revenue: 0
    requests: 0
    impressions: 0
    currency: "USD"

  sumDetailed: (data) ->
    data['revenue'] = data['requests'] = data['impressions'] = 0
    for row in data['detailed']
      data['revenue'] += row['revenue']
      data['requests'] += row['requests']
      data['impressions'] += row['impressions']

  reverse_merge: (options, overrides) ->
    @merge overrides, options

  merge: (options, overrides) ->
    @extend (@extend {}, options), overrides

  extend: (object, properties) ->
    for key, val of properties
      object[key] = val
    object

  cheerio: require('cheerio')
  csv: require('csv')
  dateFormat: require('dateformat')


  INTERVAL_TYPE_HOUR: 'HOUR'
  INTERVAL_TYPE_DAY: 'DAY'
  INTERVAL_TYPE_FEW_HOUR: 'HOURS'
  INTERVAL_TYPE_FEW_DAYS: 'FEW_DAYS'
  INTERVAL_TYPE_OTHER: 'ANOTHER'

  detect_interval_type: ->
    interval = @requested_end_date - @requested_start_date
    hours = interval / 1000 / 60 / 60
    remainder = Math.abs(hours - Math.round hours)
    if (remainder > @SMALL_NUMBER) then return @INTERVAL_TYPE_OTHER
    hours = Math.round hours
    if hours == 1 then return @INTERVAL_TYPE_HOUR
    if hours % 24 != 0 then return @INTERVAL_TYPE_FEW_HOUR
    if hours == 24 then return @INTERVAL_TYPE_DAY
    @INTERVAL_TYPE_FEW_DAYS

  SMALL_NUMBER: 0.0001

module.exports =
  Base: Base
