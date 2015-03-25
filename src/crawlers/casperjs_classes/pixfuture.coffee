CasperjsBase = (require './../casperjs.base').Crawler

class Crawler extends CasperjsBase
  timezone: 'America/Los_Angeles'
  onlyDaily: true
  scriptName: 'pixfuture'
  @website: false

module.exports =
  Crawler: Crawler