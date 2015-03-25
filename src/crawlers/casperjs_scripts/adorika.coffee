casper_helper = require './casper.helper'

casper = casper_helper.casper
helper = casper_helper.helper
#useful during development
#different messages
casper.options.timeout = 150000
#casper.enableDebug()
params = helper.params
start_date = params.start_date.format 'DD-MM-YYYY'
end_date = params.end_date.format 'DD-MM-YYYY'
casper.start 'http://pub.ad-sys.com/?promt_tenant=&from_domain=pub.adorika.net', ->
  this.fill 'form',
    username: params.username
    password: params.password
  , false
  this.click '.m_button'
casper.wait 6000, ->
  helper.checkLogin()
casper.thenOpen "http://pub.ad-sys.com/?page=reports&mode=&date_range=custom&fromDatepicker=#{start_date}&toDatepicker=#{end_date}&interval=day&time_zone=UTC&selected_filters_pub_sel=&selected_filters_pub_sel_channel=&selected_filters_index=&selected_filters_country=&selected_filters_device=&selected_filters_referer=&selected_filters_IMPS_min=&selected_filters_IMPS_max=&metrics=IMPS&metrics=CLICKS&metrics=CLICKRATE&metrics=COST&metrics=COST_ECPM&run_report=Run+Report&set_name=&set_type=private", ->
  get = (number) =>
    value = (this.fetchText "table.list > tfoot:nth-child(3) > tr:nth-child(1) > td:nth-of-type(#{number})").replace /,|\$|/g, ''
    if value == '' then 0 else value
  impressions = get 2
  clicks = get 3
  revenue = get 5
  cpm = get 6
  data =
    impressions: impressions
    requests: impressions
    clicks: clicks
    revenue: revenue
    cpm: cpm
    currency: "USD"
  helper.returnData data

casper.run()