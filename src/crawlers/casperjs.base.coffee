base = require './base'
path = require 'path'
childProcess = require 'child_process'
phantomjs = require 'phantomjs'
models = require './../models'
#just a workaround to get casperjs location in local node_modules
binPath = phantomjs.path.replace 'phantomjs/lib/phantom/bin/phantomjs', 'casperjs/bin/casperjs'
process.env.PHANTOMJS_EXECUTABLE = phantomjs.path

class CasperjsBase extends base.Base
  onlyDaily: true
  DATA_PLACEHOLDER_START: 'Crawler Data Start'
  DATA_PLACEHOLDER_END: 'Crawler Data End'

#  scriptName: 'koomona'
  scriptName: null
  params: {}

  @params: {}
  init: ->
    #calculate @start_date && @end_date for adv network's timezone
    @timezonePrepare()
    @params =
      username: @username
      password: @password
      start_date: @start_date #.format 'YYYY-MM-DD'
      end_date: @end_date #.format 'YYYY-MM-DD'
      interval_type: @detect_interval_type()
      timezone: @timezone
      requested_start_date: @requested_start_date
      requested_end_date: @requested_end_date
      headers: @headers
      DATA_PLACEHOLDER_START: @DATA_PLACEHOLDER_START
      DATA_PLACEHOLDER_END: @DATA_PLACEHOLDER_END
      loginURL: @loginURL
      home: @home
      errorDbId: @errorDbId
    @params.crawlerName = @crawlerName if @crawlerName

  run: (cb)  ->
    process.env.PHANTOMJS_EXECUTABLE = phantomjs.path
    
    childArgs = [
      path.join(__dirname, 'casperjs_scripts', "#{@scriptName}.coffee"),
      JSON.stringify @params
    ]
    childArgs.push "--ignore-ssl-errors=true"
    childProcess.execFile binPath, childArgs, (err, stdout, stderr) =>
      
      console.log err if err
      console.log stderr if stderr
      console.log stdout

      reg = new RegExp "RETURN_DATA#{@DATA_PLACEHOLDER_START }([\\s\\S]+)#{@DATA_PLACEHOLDER_END}"
      res = stdout.match reg
      
      if res then data = JSON.parse res[1] else data = null
      
      reg = new RegExp 'Authorization failed'
      res = stdout.match reg
   
      if res
        errorData =
          id: @params.errorDbId
          status: "breaked by login"
          error_id: 3
        models.AdNetworkError.edit errorData

      cb data # if data
      #throw 'Empty data from casperjs' unless data

module.exports =
  Crawler: CasperjsBase
