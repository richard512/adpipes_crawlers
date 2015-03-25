casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper

#useful during development
#different messages
#casper.enableDebug()
params = helper.params
casper.options.timeout = 30000
casper.options.waitTimeout = 30000

casper.start 'https://exchange.pulsepoint.com/AccountMgmt/Login.aspx?app=publisher', ->
  @evaluate (username, password) =>
    $('#UserName').val username
    $('#Password').val password
    WebForm_DoPostBackWithOptions new WebForm_PostBackOptions 'LoginButton', '', true, 'vgLogIn', '', false, true
  , params.username, params.password

casper.then ->
  helper.checkLogin()

casper.waitForUrl /Dashboard/

casper.thenClick 'div.manager'

casper.then ->
  start_date = params.start_date.format 'MM/DD/YYYY'
  end_date = params.end_date.format 'MM/DD/YYYY'
  this.evaluate ((start_date, end_date) ->
      document.getElementById('rbpredifedDates').setAttribute('checked', false)
      document.getElementById('rbCustomDates').setAttribute('checked', true)
      document.querySelector('#txtStartDate').value = start_date
      document.querySelector('#txtEndDate').value = end_date
      $('a.active').trigger 'click'
    )
  , start_date, end_date

casper.then ->
  dateError = this.fetchText('#dateError')
  if dateError isnt 'undefined'
    throw new Error dateError
  data = this.evaluate ->
    window.pmr.Model.getAccountManagementReportData false

  detailed = []
  AdTagGroups = data.AdTagGroups
  for group in AdTagGroups
    AdTags = group.AdTags
    for adTag in AdTags
      detailed.push
        ad_tag: adTag.AdTagId
        custom_channel: group.AdTagGroupId
        revenue: adTag.Revenue
        impressions: adTag.PaidImps
        fill_rate: adTag.FillRate
        requests: adTag.TotalImps
        clicks: adTag.Clicks
        ctr: adTag.CTR
        cpc: adTag.CPC
        cpm: adTag.AvgCPM
        currency: "USD"
        json:
          AdTagName: adTag.AdTagName
          AdTagGroupName: group.AdTagGroupName
          AskPrice: adTag.AskPrice,
          BackupImps: adTag.BackupImps
          IsActive: adTag.IsActive
          IsLocked: adTag.IsLocked
          Size: adTag.Size
          Status: adTag.Status
          WasActive: adTag.WasActive
          WasAskPrice: adTag.WasAskPrice
          WasLocked: adTag.WasLocked

  reportdata =
    revenue: data.RevenueTotal
    impressions: data.PaidImpsTotal
    fill_rate: data.FillRateTotal
    requests: data.ImpsTotal
    clicks: data.ClicksTotal
    ctr: data.CTRTotal
    cpc: data.CPCTotal
    cpm: data.AvgCPMTotal
    currency: "USD"
    detailed: detailed
    json:
      BackupImpsTotal: data.BackupImpsTotal
      TimeString: data.TimeString
  helper.returnData reportdata

casper.run()