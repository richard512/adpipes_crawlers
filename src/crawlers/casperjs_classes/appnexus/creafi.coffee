CasperjsBase = (require './../../casperjs.base.coffee').Crawler

class Crawler extends CasperjsBase
  timezone: 'EST'
  onlyDaily: false
  scriptName: 'appnexus.com'
  crawlerName: 'creafi'  #for debugging
  loginURL: 'http://user.creafi-online-media.com'
  @website: false

module.exports =
  Crawler: Crawler