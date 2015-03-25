CasperjsBase = (require './../../casperjs.base.coffee').Crawler

class Crawler extends CasperjsBase
  timezone: 'EST'
  onlyDaily: false
  scriptName: 'appnexus.com'
  crawlerName: 'mediashakers.com'   #for debugging
  loginURL: 'http://console.mediashakers.com'
  @website: false

module.exports =
  Crawler: Crawler