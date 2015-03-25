base = require './base'
str_parser = require './string_parser'

class Crawler extends base.Base
  onlyDaily: true
  timezone: 'EST'
  home: 'https://publisher.adconductor.com/Reports/ReportBuilder.aspx'
  loginURL: 'https://publisher.adconductor.com/login.aspx'
  loginForm: 
    return_url: 'welcome'
    return_user: ''
  @website: false

  init: ->
    @timezonePrepare()

  extract: ($, cb, err, resp) ->
    ctl00_RadTabStrip1_ClientState = 
      selectedIndexes: ['2', '2:0']
      logEntries:[]
      scrollState: {}

    ctl00_MainContent_RadDatePicker1_dateInput_ClientState = 
      enabled:true
      emptyMessage: ''
      validationText: @start_date.format 'YYYY-MM-DD-00-00-00'
      valueAsString: @start_date.format 'YYYY-MM-DD-00-00-00'
      minDateStr: "1980-01-01-00-00-00"
      maxDateStr: "2099-12-31-00-00-00"
    
    ctl00_MainContent_RadDatePicker2_dateInput_ClientState = 
      enabled: true
      emptyMessage: ''
      validationText: @end_date.format 'YYYY-MM-DD-00-00-00'
      valueAsString: @end_date.format 'YYYY-MM-DD-00-00-00'
      minDateStr: "1980-01-01-00-00-00"
      maxDateStr: "2099-12-31-00-00-00"
    
    form = 
      __PREVIOUSPAGE: $('#__PREVIOUSPAGE').val()
      __VIEWSTATE: $('#__VIEWSTATE').val()
      ctl00_RadTabStrip1_ClientState: JSON.stringify ctl00_RadTabStrip1_ClientState
      ctl00_MainContent_RadToolTip1_ClientState: ''
      ctl00$MainContent$ddl_time_range: 'fixed'
      ctl00$MainContent$RadDatePicker1: @start_date.format 'YYYY-MM-DD'
      ctl00$MainContent$RadDatePicker1$dateInput: @start_date.format 'M/D/YYYY'
      ctl00_MainContent_RadDatePicker1_dateInput_ClientState: JSON.stringify ctl00_MainContent_RadDatePicker1_dateInput_ClientState
      ctl00_MainContent_RadDatePicker1_calendar_SD: [[@start_date.year(), @start_date.month() + 1, @start_date.date()]]
      ctl00_MainContent_RadDatePicker1_calendar_AD: [[1980,1,1], [2099,12,30], [@start_date.year(), @start_date.month() + 1, 1]]
      ctl00_MainContent_RadDatePicker1_ClientState: ''
      ctl00$MainContent$RadDatePicker2: @end_date.format 'YYYY-MM-DD'
      ctl00$MainContent$RadDatePicker2$dateInput: @end_date.format 'M/D/YYYY'
      ctl00_MainContent_RadDatePicker2_dateInput_ClientState: JSON.stringify ctl00_MainContent_RadDatePicker2_dateInput_ClientState
      ctl00_MainContent_RadDatePicker2_calendar_SD: [@end_date.year(), @end_date.month() + 1, @end_date.date()]
      ctl00_MainContent_RadDatePicker2_calendar_AD: [[1980,1,1], [2099,12,30], [@end_date.year(), @end_date.month() + 1, new Date().getDate()]]
      ctl00_MainContent_RadDatePicker2_ClientState: ''
      ctl00$MainContent$ddl_totalby1: 'date'
      ctl00$MainContent$ddl_totalby2: 'adcode'
      ctl00$MainContent$rbl_ad_size: 0
      ctl00$MainContent$rbl_adcode: 0
      ctl00$MainContent$cbl_columns$0: 'totalviews'
      ctl00$MainContent$cbl_columns$1: 'paidviews'
      ctl00$MainContent$cbl_columns$2: 'defaultviews'
      ctl00$MainContent$cbl_columns$3: 'fillrate'
      ctl00$MainContent$cbl_columns$4: 'clicks'
      ctl00$MainContent$cbl_columns$5: 'ctr'
      ctl00$MainContent$cbl_columns$6: 'ecpm'
      ctl00$MainContent$cbl_columns$7: 'amtearned'
      ctl00$MainContent$tb_reportname: 'Fixed Range by Day, by AdCode'
      ctl00_MainContent_RadGrid1_ClientState: ''
      __EVENTTARGET: 'ctl00$MainContent$btn_downloadExcel'
      __EVENTARGUMENT: ''
      __LASTFOCUS: ''

    @request @home, {method: 'POST', form: form}, (err, res, body) =>
      console.log err if err
      
      moment = require 'moment-timezone'
      $ = @cheerio.load body
      records = $ 'table tr'

      sd = @start_date.format 'MM/DD/YYYY'
      ed = @end_date.format 'MM/DD/YYYY'

      report = @emptyData()
      report =
        detailed: []
        currency: 'GBR'

      records[1...-2].each (i, el) ->
        cells = $(@).find('td')
        reportDate = moment $(cells[0]).text()

        if (reportDate.isSame sd) or (reportDate.isSame ed) or (reportDate.isBetween sd, ed)
          
         try
           reportData = 
            currency: 'GBR'
            ad_tag: $(cells[1]).text()
            impressions: $(cells[2]).text()
            fill_rate: $(cells[5]).text()
            clicks: $(cells[6]).text()
            ctr: $(cells[7]).text()
            cpm: $(cells[8]).text()
            revenue: $(cells[9]).text()
            json:
              day: $(cells[0]).text()
              paid_views: $(cells[3]).text()
              default_views: $(cells[4]).text()
         catch e
           reportData =
              revenue: 0
              cpm: 0
              impressions: 0
              clicks: 0
              ad_tag: 0
              fill_rate: 0
              currency: "GBR"
        #console.log reportData
        cb reportData
module.exports =
  Crawler: Crawler  