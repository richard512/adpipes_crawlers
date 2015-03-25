CasperjsBase = (require './../casperjs.base').Crawler

class Crawler extends CasperjsBase
  timezone: 'GMT'
  onlyDaily: true
  scriptName: 'skimlinks.com'
  allowEmptyImpressions = true
  allowEmptyRequests = true
  @website: false

module.exports =
  Crawler: Crawler