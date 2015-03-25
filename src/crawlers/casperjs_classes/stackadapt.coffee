CasperjsBase = (require './../casperjs.base').Crawler

class Crawler extends CasperjsBase
  timezone: 'EST'
  onlyDaily: true
  scriptName: 'stackadapt'
  @website: false

module.exports =
  Crawler: Crawler
