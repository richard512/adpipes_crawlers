CasperjsBase = (require './../casperjs.base').Crawler

class Crawler extends CasperjsBase
  timezone: 'EST'
  onlyDaily: false
  scriptName: 'appnexus.com'
  crawlerName: 'adnubo'   #for debugging
  loginURL: 'http://console.adnubo.com'
  @website: false

module.exports =
  Crawler: Crawler