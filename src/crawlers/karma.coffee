base = require './base'
str_parser = require './string_parser'

class Crawler extends base.Base
  loginURL : 'https://target.zedo.com/servlet/LoginServlet'
  dataURL : 'https://target.zedo.com/Main?reporttype=mbc&reportname=Quick_Profit_Report'

  timezone: 'America/New_York'
  onlyDaily: true
  @website: false
  
  init: ->
    @timezonePrepare()
    @loginForm =
    	rem: 0
    	form : 'login'
    	fromSupport : 'no'
    	fromEmail : 'false'
    	uid : @username
    	pwd : @password


  process : (err, resp, body, cb) ->
    params =
      method : 'POST'
      form :
        step:'submit'
        event_key:'profit_rpt'
        mobilereport:'off'
        scheduler:'NO'
        reporttypeName:'Publisher Report'
        report:0
        tperiod:'summary'
        timePeriod:'summary'
        i18n_startDate:@start_date.format 'MM/DD/YYYY'
        startDate:@start_date.format 'MM/DD/YYYY'
        i18n_endDate:@end_date.format 'MM/DD/YYYY'
        endDate:@end_date.format 'MM/DD/YYYY'
        advertiserType:-1
        advertiser:-1
        campaign:-1
        revenueTypeFilter:-1
        actionTypeFilter:'post_total'
        publisher:-1
        channel:-1
        dimension:-1
        country:-1
        state:-1
        metro:-1
        nwtId:2812
    @request @dataURL, params, (err, resp, body) =>
      @extract @cheerio.load(body), cb, err, resp


  extract : ($, cb, err, resp) ->
    return unless @checkLogin $
    arr =  ($ '#table-1 tr').eq(2).find('td')
    data = {}
    try
      data['True Imps'] = str_parser.toInt(arr.eq(2).text())
      data['Assigned Events'] = str_parser.toInt(arr.eq(3).text())
      data['Total Actions'] = str_parser.toInt(arr.eq(6).text())
      data['Total PiActions'] = str_parser.toInt(arr.eq(7).text())
      data['ConversionRate'] = str_parser.toFloat(arr.eq(8).text())
      data['TotalPayout($)'] = str_parser.toFloat(arr.eq(10).text())
      data['eCPM for Advertiser($)'] = str_parser.toFloat(arr.eq(11).text())
      data['Profit($)'] = str_parser.toFloat(arr.eq(13).text())
      reportData =
        impressions : str_parser.toInt(arr.eq(1).text())
        requests : str_parser.toInt(arr.eq(1).text())
        cpm : str_parser.toFloat(arr.eq(12).text())
        revenue: str_parser.toFloat(arr.eq(5).text())
        clicks : str_parser.toInt(arr.eq(4).text())
        ctr : str_parser.toFloat(arr.eq(5).text())
        currency: 'USD'
        json : data
    catch e
      reportData =
        revenue: 0
        requests: 0
        impressions: 0
        currency: "USD"
    cb reportData

module.exports = Crawler : Crawler
