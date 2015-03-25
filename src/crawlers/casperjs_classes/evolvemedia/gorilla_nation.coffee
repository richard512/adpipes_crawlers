CasperjsBase = (require './../../casperjs.base.coffee').Crawler

class Crawler extends CasperjsBase
  @website: false
  timezone: 'EST'
  onlyDaily: true
  scriptName: 'gorilla_nation'

module.exports =
  Crawler: Crawler