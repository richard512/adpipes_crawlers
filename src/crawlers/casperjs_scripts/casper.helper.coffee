require = patchRequire global.require;
moment = require 'moment-timezone'
casper = require('casper').create
  timeout: 30000
  waitTimeout: 20000
  pageSettings:
    loadImages: false
    loadPlugins: true

params = JSON.parse casper.cli.get 0

console.log '__________________________'
console.log '[CASPERJS EXECUTED BY]'
escapedParams = '"' + (casper.cli.get 0).replace(/"/g, '\\"') + '"'
console.log casper.cli.options['casper-path'] + '/bin/casperjs ', casper.cli.get 1, escapedParams
console.log '__________________________'
params.start_date = moment params.start_date
params.end_date = moment params.end_date

params.start_date.tz params.timezone
params.end_date.tz params.timezone
params.requested_start_date = moment params.requested_start_date
params.requested_end_date = moment params.requested_end_date

casper.userAgent params.headers['User-Agent']
casper.options.viewportSize = width: 1600, height: 1024 
casper.enableDebug = ->
  casper.options.verbose = true
  casper.options.logLevel = 'debug'

  casper.on 'remote.message', (msg) ->
    this.echo 'remote message caught' + msg

  casper.on 'page.error', (msg, trace) ->
    this.echo 'Page error: ' + msg, 'ERROR'

  casper.on 'resource.error', (resourceError) ->
    console.log 'Unable to load resource (#' + resourceError.id + 'URL:' + resourceError.url + ')'
    console.log 'Error code: ' + resourceError.errorCode + '. Description: ' + resourceError.errorString

checkLogin = (selector)->
    selector = "input[type=password]" unless selector
    if casper.exists(selector)
      errorData =
        id: params.errorDbId
        status: "breaked by login"
        error_id: 3
      console.log 'Authorization failed'
      throw "Authorization failed for user " + params.username

returnData = (data) ->
  casper.echo 'RETURN_DATA'+params.DATA_PLACEHOLDER_START
  casper.echo JSON.stringify data
  casper.echo params.DATA_PLACEHOLDER_END

emptyData = ->
  revenue: 0
  requests: 0
  impressions: 0
  currency: "USD"

module.exports =
  casper: casper
  helper:
    params: params
    returnData: returnData
    emptyData: emptyData
    checkLogin: checkLogin
