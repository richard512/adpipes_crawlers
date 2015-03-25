CasperjsBase = (require './../../casperjs.base.coffee').Crawler

class Crawler extends CasperjsBase
  timezone: 'EST'
  onlyDaily: false
  scriptName: 'appnexus.com'
  crawlerName: 'cpmbooster'  #for debugging
  loginURL: 'http://console.resultsaccelerator.net'
  @website: false

module.exports =
  Crawler: Crawler