CasperjsBase = (require './../casperjs.base').Crawler

class Crawler extends CasperjsBase
  timezone: 'America/Los_Angeles'
  onlyDaily: true
  scriptName: 'glammedia'
  @website: false

module.exports =
  Crawler: Crawler
