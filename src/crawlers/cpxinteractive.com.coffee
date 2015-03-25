base = require './base'
str_parser = require './string_parser'

#can be based on mediashakers crawler, as it using the same server
class Crawler extends base.Base
  timezone: 'GMT'
  onlyDaily: true

  loginURL: 'http://p.cpxinteractive.com/index/sign-in'
  loginForm:
    redir: ''
    app_id: ''
    app_redirect: ''
  @website: true

  init: ->
    #calculate @start_date && @end_date for adv network's timezone
    @timezonePrepare()
  process: (err, resp, body, cb) =>
    start_date = @start_date.format 'MM/DD/YYYY'
    end_date = @end_date.format 'MM/DD/YYYY'
    getIdURL = 'http://p.cpxinteractive.com/14.21.43/report/get-id?report%5Bcategory%5D=publisher_login&report%5Btype%5D=analytics&report%5Bformat%5D=standard&report%5Brange%5D=custom&report%5Bstart_date%5D=' + start_date + '&report%5Bend_date%5D=' + end_date + '&report%5Binterval%5D=cumulative&report%5Btimezone%5D=EST5EDT&report%5Bmetrics%5D%5B%5D=imps_total&report%5Bmetrics%5D%5B%5D=clicks&report%5Bmetrics%5D%5B%5D=click_thru_pct&report%5Bmetrics%5D%5B%5D=total_convs&report%5Bmetrics%5D%5B%5D=convs_rate&report%5Bmetrics%5D%5B%5D=convs_per_mm&report%5Bmetrics%5D%5B%5D=publisher_revenue&report%5Bmetrics%5D%5B%5D=publisher_rpm&report%5Bgroup_by%5D%5B%5D=site_id&report%5Bgroup_by%5D%5B%5D=placement_id&report%5Brun_type%5D=run_now&report%5Bemail_format%5D=excel&report%5Bpre_send_now_email_addresses%5D=affiliate%40bigsoccer.com&report%5Bschedule_when%5D=daily&report%5Bschedule_format%5D=excel&report%5Bschedule_email_addresses%5D=&report%5Bname%5D=&report%5Btimezone%5D=EST5EDT'
    try   
      @request getIdURL, {method: 'POST'}, (err, resp, body) =>
      @request 'http://p.cpxinteractive.com/report/export?report_id=' + JSON.parse(body)['report_id'] + '&entity_id=0&type=csv', (err, resp, body) =>
        @csv.parse body, (err, data) =>
          dataResponse =
            detailed: []
            currency: 'USD'
          data = data[1...-6]
          for record of data
            if data[record]?
              try
                reportData =
                  website: data[record][0]
                  ad_slot: data[record][1]
                  revenue: str_parser.toFloat data[record][9]
                  requests: str_parser.toInt data[record][2]
                  impressions: str_parser.toInt data[record][3]
                  clicks: str_parser.toInt data[record][4]
                  ctr: (str_parser.toFloat  data[record][5]) / 100
                  currency: 'USD'        
              catch e
                reportData =
                  revenue: 0
                  requests: 0
                  impressions: 0
                  currency: "USD"
          console.log reportData    
          cb reportData
    catch e
      reportData =
        revenue: 0
        requests: 0
        impressions: 0
        currency: "USD"
    #console.log reportData   
    cb reportData
            


module.exports =
  Crawler: Crawler