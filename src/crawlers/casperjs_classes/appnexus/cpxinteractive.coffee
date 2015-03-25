CasperjsBase = (require './../../casperjs.base.coffee').Crawler

class Crawler extends CasperjsBase
  timezone: 'EST'
  onlyDaily: false
  scriptName: 'appnexus.com'
  crawlerName: 'cpxinteractive'  #for debugging
  loginURL: 'http://p.cpxinteractive.com/index/sign-in'
  @website: false

module.exports =
  Crawler: Crawler