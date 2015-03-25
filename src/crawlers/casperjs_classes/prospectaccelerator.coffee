CasperjsBase = (require './../casperjs.base').Crawler

class Crawler extends CasperjsBase
  timezone: 'UTC'
  onlyDaily: false
  scriptName: 'prospectaccelerator'
  @website: true

module.exports =
  Crawler: Crawler