casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper
#useful during development
#different messages
#casper.enableDebug()
casper.options.timeout = 80000
casper.options.waitTimeout = 80000
params = helper.params
start_date = params.start_date.format 'YYYY-MM-DD'
end_date = params.end_date.format 'YYYY-MM-DD'

casper.start 'http://station.intag.co/login/', ->
  this.fill 'form.form-signin',
    username: params.username
    password: params.password
  , true

authCompleted = ->
  casper.getCurrentUrl().match(/dashboard/) or casper.exists('div.alert-danger')

casper.waitFor authCompleted, ->
  helper.checkLogin()

casper.thenOpen 'http://station.intag.co/pub/stats/sites/all/'

casper.waitForSelector "#reports-form", ->
  links = casper.evaluate ->
    links = document.querySelectorAll('.sites-navigation a.btn')
    result =
      sites: []
    for link in links
      if link.innerText == "All sites"
        result.all_sites_link = link.getAttribute('href')
      else
        result.sites.push
          link: link.getAttribute('href')
          name: link.innerText
    result

  detailed = []
  url = "http://station.intag.co"
  query = "?fragment_update=stats&stats_group_by=*&stats_start_date=#{start_date}&stats_end_date=#{end_date}&stats_granularity=*&stats_sort_by=-period"
  getData = (content)->
    #RegExp used because content is html fragment, and casper.fetchText() doesn't work
    reg = new RegExp("<tbody>([\\s\\S]+)</tbody>")
    table_content = content.match(reg)[0].split('&#32;')
    if table_content.length < 3
      return helper.emptyData()
    result =
      currency: "USD"
      revenue: str_parser.toFloat table_content[8]
      requests: str_parser.toInt table_content[3]
      impressions: str_parser.toInt table_content[3]
      clicks: str_parser.toInt table_content[4]
      ctr: str_parser.toFloat table_content[6]
      cpm: str_parser.toFloat table_content[9]
      json:
        Conversions: str_parser.toInt table_content[5]
        "Conversion Rate%": str_parser.toFloat table_content[8]
    return result

  for site in links.sites
    casper.thenOpen url + site.link + query, ->
      dataBySite = getData casper.getPageContent()
      dataBySite.website = site.name
      detailed.push dataBySite

  casper.thenOpen url + links.all_sites_link + query, ->
    data = getData casper.getPageContent()
    data.detailed = detailed
    helper.returnData data

casper.run()
