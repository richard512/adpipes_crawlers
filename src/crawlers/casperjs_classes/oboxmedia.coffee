CasperjsBase = (require './../casperjs.base').Crawler

class Crawler extends CasperjsBase
  timezone: 'EST'
  onlyDaily: true
  scriptName: 'oboxmedia'
  @website: true

module.exports =
  Crawler: Crawler