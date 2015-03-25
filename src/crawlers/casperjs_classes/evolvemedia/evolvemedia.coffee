CasperjsBase = (require './../../casperjs.base.coffee').Crawler

class Crawler extends CasperjsBase
  timezone: 'EST'
  onlyDaily: true
  scriptName: 'evolvemedia'
  @website: false

module.exports =
  Crawler: Crawler

###
All revenue reflected in your earnings report are ESTIMATES ONLY until final revenue has been fully reconciled.
Due to the complexity of our campaigns and billing, final revenue figures are not reconciled
until on or around the 15th business day of the following month.
Please note that there are many factors that can affect final earnings such as over/under delivery,
the nature and type of ad units or overall media sold, 3rd party reporting discrepancies,
in-flight campaign adjustments and, human error.
Please reach out to your Publisher Services Manager if you have any questions on mid-month report generation. ###