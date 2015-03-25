base = require './base'
str_parser = require './string_parser'

class Crawler extends base.Base
  onlyDaily: true
  timezone: 'EST'
  home: 'http://v2.ybrantcompass.com/onetag/reports/download'
  loginURL: 'http://v2.ybrantcompass.com/onetag/login/'
  loginForm: 
    return_url: 'welcome'
    return_user: ''
  @website: false

  init: ->
    @timezonePrepare()

  extract: ($, cb, err, resp) ->    
    search_query_string =
      timezone_type: 'EST'
      multiselect_timezone_type: 'EST'
      time_frame: 'custom'
      multiselect_time_frame: 'custom'
      start_date: @start_date.format 'YYYY-MM-DD HH:mm:ss'
      end_date: @end_date.format 'YYYY-MM-DD HH:mm:ss'
      interval: 'day'
      multiselect_interval: 'day'
      tag_grp: 'on'
      sizes_grp: 'on'
      metrics: [0,3,5,6,7,8,9,10,11,12]
      multiselect_metrics: '12'
      showOptions: ['Date Interval', 'Size', 'Tags']
      timezone: 'EST'
      run_option: 'show'
      export_format: 'csv'
      export_dest: 'download'
      report_save_name: ''
      report_schedule: 'daily'
      report_schedule_email: ''
      reports: 'Run Report'

    form = 
      search_query_string: JSON.stringify search_query_string
      export_to: 'XLS',
      filename: 'mySpreadsheet',
      format: 'csv'

    @request @home, {method: 'POST', form: form}, (err, res, body) =>
      @csv.parse body, (err, data) =>
        report = @emptyData()
        report.detailed = []

        if data.length > 1
          for record in data[1...-1]
            tempReport = 
              currency: 'USD'
              ad_tag: record[2]
              impressions: record[3]
              clicks: record[4]
              ctr: record[6]
              revenue: record[8]
              cpm: record[9]
            report.detailed.push tempReport
        cb report

module.exports =
  Crawler: Crawler