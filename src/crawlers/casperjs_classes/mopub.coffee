CasperjsBase = (require './../casperjs.base').Crawler

class Crawler extends CasperjsBase
  timezone: 'UTC'
  onlyDaily: true
  scriptName: 'mopub'
  @website: false

module.exports =
  Crawler: Crawler
