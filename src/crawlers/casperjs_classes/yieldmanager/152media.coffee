CasperjsBase = (require './../../casperjs.base').Crawler

class Crawler extends CasperjsBase
  timezone: 'EST'
  onlyDaily: true
  scriptName: 'my.yieldmanager.com'
  @website: false

module.exports =
  Crawler: Crawler
