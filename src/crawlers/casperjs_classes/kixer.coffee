CasperjsBase = (require './../casperjs.base').Crawler

class Crawler extends CasperjsBase
  timezone: 'Canada/Yukon'
  onlyDaily: true
  scriptName: 'kixer'
  @website: false

module.exports =
  Crawler: Crawler
