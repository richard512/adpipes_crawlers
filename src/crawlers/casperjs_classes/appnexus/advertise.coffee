CasperjsBase = (require './../../casperjs.base.coffee').Crawler

class Crawler extends CasperjsBase
  timezone: 'EST'
  onlyDaily: false
  scriptName: 'appnexus.com'
  crawlerName: 'advertise'   #for debugging
  loginURL: 'http://portal.advertise.com'
  @website: false

module.exports =
  Crawler: Crawler