CasperjsBase = (require './../../casperjs.base.coffee').Crawler

class Crawler extends CasperjsBase
  timezone: 'EST'
  onlyDaily: false
  scriptName: 'appnexus.com'
  crawlerName: 'yellowhammer'    #for debugging
  loginURL: 'http://wardog.clickhype.com'
  @website: false

module.exports =
  Crawler: Crawler