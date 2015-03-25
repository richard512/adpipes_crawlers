CasperjsBase = (require './../../casperjs.base.coffee').Crawler

class Crawler extends CasperjsBase
  timezone: 'EST'
  onlyDaily: false
  scriptName: 'appnexus.com'
  crawlerName: 'matomymedia.com'   #for debugging
  loginURL: 'http://console.matomymedia.com'
  @website: false

module.exports =
  Crawler: Crawler