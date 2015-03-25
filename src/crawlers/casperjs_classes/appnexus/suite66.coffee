CasperjsBase = (require './../../casperjs.base.coffee').Crawler

class Crawler extends CasperjsBase
  timezone: 'EST'
  onlyDaily: false
  scriptName: 'appnexus.com'
  crawlerName: 'suite66'  #for debugging
  loginURL: 'http://admin.suite6ixty6ix.com'
  @website: false

module.exports =
  Crawler: Crawler