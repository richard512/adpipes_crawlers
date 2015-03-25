CasperjsBase = (require './../casperjs.base').Crawler

class Crawler extends CasperjsBase
  @website: false
  timezone: 'GMT'
  onlyDaily: true
  scriptName: 'koomona'

module.exports =
  Crawler: Crawler