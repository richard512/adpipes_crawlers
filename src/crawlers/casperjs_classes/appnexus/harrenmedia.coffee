CasperjsBase = (require './../../casperjs.base.coffee').Crawler

class Crawler extends CasperjsBase
  timezone: 'EST'
  onlyDaily: false
  scriptName: 'appnexus.com'
  crawlerName: 'harrenmedia'  #for debugging
  loginURL: 'http://console.networkhm.com'
  @website: false

module.exports =
  Crawler: Crawler