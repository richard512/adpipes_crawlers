CasperjsBase = (require './../../casperjs.base.coffee').Crawler

class Crawler extends CasperjsBase
  timezone: 'EST'
  onlyDaily: false
  scriptName: 'appnexus.com'
  crawlerName: 'mediawhite' #for debugging
  loginURL: 'http://console.appnexus.com'
  @website: false

module.exports =
  Crawler: Crawler