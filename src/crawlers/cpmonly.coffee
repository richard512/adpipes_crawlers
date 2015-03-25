base = require './base'

class Crawler extends base.Base
  onlyDaily: true
  timezone: 'UTC'
  home: 'http://beta.cpmonly.com/report/publisher'
  getIdURL: 'http://beta.cpmonly.com/14.29.15/report/get-id'
  loginURL: 'http://beta.cpmonly.com/index/sign-in'
  reportURL: 'http://beta.cpmonly.com/report/export'
  loginForm: 
    redir: ''
    app_id: ''
    app_redirect: ''
  @website: false

  init: ->
    @timezonePrepare()

  extract: ($, cb, err, resp) ->
    getIdForm = 
      report:
        category: 'publisher_login'
        type: 'analytics'
        format: 'standard'
        range: 'custom'
        start_date: @start_date.format 'MM/DD/YYY'
        end_date: @end_date.format 'MM/DD/YYY'
        interval:'day'
        timezone: 'UTC'
        metrics: ['imps_filled', 'imps_default', 'clicks', 'click_thru_pct', 'total_convs', 'convs_rate', 'convs_per_mm', 'publisher_revenue', 'publisher_rpm', 'publisher_filled_revenue', 'publisher_filled_rpm', 'publisher_default_revenue', 'publisher_default_rpm']
        show_usd_currency: true
        group_by: ['day']
        fixed_columns: ['day']
        group_by: ['site_id', 'placement_id', 'media_type', 'geo_country', 'size', 'publisher_currency']
        run_type: 'run_now'
        email_format: 'excel'
        pre_send_now_email_addresses: ''
        schedule_when: 'daily'
        schedule_format:'excel'
        schedule_email_addresses: ''
        name: ''
    @request @getIdURL, {method: 'POST', form: getIdForm}, (err, resp, body) =>
      queryString = 
        report_id: JSON.parse(body).report_id
        entity_id: 0
        type: 'csv'
      @request @reportURL, qs: queryString, (err, resp, body) =>
        console.log err if err
        report = @emptyData()
        report.detailed = []
        @csv.parse body, (err, data) ->
          for record in data[1..-7]
            report.detailed.push
              ad_tag: record[0]
              currency: record[5]
              impressions: record[6]
              clicks: record[10]
              ctr: record[11]
              revenue: record[16]
              json:
                placement: record[1]
                media_type: record[2]
                geo_country_name: record[3]
                size: record[4]
                imps_sold: record[7]
                imps_filled: record[8]
                imps_default: record[9]
                total_convs: record[12]
                convs_rate: record[13]
                convs_per_million: record[14]
                publisher_revenue_pub_curr: record[15]
                publisher_rpm_pub_curr: record[17]
                publisher_rpm: record[18]
                publisher_filled_revenue: record[19]
                publisher_filled_rpm: record[20]
                publisher_default_revenue: record[21]
                publisher_default_rpm: record[22]
          cb report

module.exports =
  Crawler: Crawler  
