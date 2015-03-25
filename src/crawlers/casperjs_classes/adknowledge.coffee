CasperjsBase = (require './../casperjs.base').Crawler

class Crawler extends CasperjsBase
  timezone: 'EST'
  onlyDaily: true
  scriptName: 'adknowledge'
  @website: false

module.exports =
  Crawler: Crawler
