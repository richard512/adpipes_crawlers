CasperjsBase = (require './../casperjs.base').Crawler

class Crawler extends CasperjsBase
  timezone: 'GMT'
  onlyDaily: true
  scriptName: 'criteo2.com'
  @website: false

module.exports =
  Crawler: Crawler