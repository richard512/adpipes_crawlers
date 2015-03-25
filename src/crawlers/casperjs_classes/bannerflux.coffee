CasperjsBase = (require './../casperjs.base').Crawler

class Crawler extends CasperjsBase
  timezone: 'America/New_York'
  onlyDaily: true
  scriptName: 'bannerflux'
  @website: false

module.exports =
  Crawler: Crawler
