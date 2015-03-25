CasperjsBase = (require './../../casperjs.base.coffee').Crawler

class Crawler extends CasperjsBase
  timezone: 'EST'
  onlyDaily: false
  scriptName: 'appnexus.com'
  crawlerName: 'deliads'  #for debugging
  loginURL: 'http://console.deliads.com'
  @website: false

module.exports =
  Crawler: Crawler