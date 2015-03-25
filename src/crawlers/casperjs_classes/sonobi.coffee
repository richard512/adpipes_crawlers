CasperjsBase = (require './../casperjs.base').Crawler

class Crawler extends CasperjsBase
  timezone: 'GMT'
  onlyDaily: true
  scriptName: 'sonobi'
  @website: false

module.exports =
  Crawler: Crawler