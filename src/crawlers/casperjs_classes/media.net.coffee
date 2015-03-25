CasperjsBase = (require './../casperjs.base').Crawler

class Crawler extends CasperjsBase
  timezone: 'UTC'
  onlyDaily: true
  scriptName: 'media.net'
  @website: false

module.exports =
  Crawler: Crawler