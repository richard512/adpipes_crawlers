CasperjsBase = (require './../casperjs.base').Crawler

class Crawler extends CasperjsBase
  timezone: 'GMT'
  onlyDaily: true
  scriptName: 'pulsepoint'
  @website: false

module.exports =
  Crawler: Crawler