CasperjsBase = (require './../casperjs.base').Crawler

class Crawler extends CasperjsBase
  timezone: 'Australia/Melbourne'
  onlyDaily: true
  scriptName: 'appnext'
  @website: false

module.exports =
  Crawler: Crawler