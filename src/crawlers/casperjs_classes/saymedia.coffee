CasperjsBase = (require './../casperjs.base').Crawler

class Crawler extends CasperjsBase
  timezone: 'GMT'
  onlyDaily: true
  scriptName: 'saymedia'
  @website: false

module.exports =
  Crawler: Crawler
