CasperjsBase = (require './../../casperjs.base.coffee').Crawler

class Crawler extends CasperjsBase
  timezone: 'EST'
  onlyDaily: true
  scriptName: 'gwallet'
  @website: false

module.exports =
  Crawler: Crawler
