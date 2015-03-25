base = require './base'
str_parser = require './string_parser'

class Crawler extends base.Base
  timezone: 'EST'
  onlyDaily: true
  @website: false

  init: ->
    #calculate @start_date && @end_date for adv network's timezone
    @timezonePrepare()

  loginURL : 'https://trioninteractive.com/s/login.php'

  process : (err, resp, body, cb) ->
    start_date = @start_date.format 'YYYY-MM-DD'
    end_date = @start_date.format 'YYYY-MM-DD'
    url = 'https://trioninteractive.com/s/phpScripts/getReportingData.php?startDate=' + start_date + '&endDate=' + end_date + '&displayName=' + @username + '&sid=' + JSON.stringify(@cookieJar).match(/\w{32}/g) + '&cb=1411140955110'
    @request url, (err, resp, body) =>
      response = JSON.parse body
      if response.error
        throw new Error response.error
      for day, i in response
        for key of day
          if key == start_date
            #we support only for one day
            data =
              currency: 'USD'
              detailed: []
            report = day[key]
            #something like report[0] - just accessing the only property of the object
            report = report[Object.keys(report)[0]]
            website = Object.keys(report)[0]
            #it should be two times
            report = report[Object.keys(report)[0]]
            for adUnit of report
              if report[adUnit]['premium']?
                for premiumAdSlot of report[adUnit]['premium']
                  r = report[adUnit]['premium'][premiumAdSlot]
                  data.detailed.push
                    ad_tag: adUnit
                    ad_slot: premiumAdSlot
                    revenue : r["revenue"]
                    impressions : r["impressions"]
                    requests : r["impressions"] + (if r["passbacks"] then r['passbacks'] else 0)
                    website: website
                    cpm : r["cpm"]
                    currency: 'USD'
              r = report[adUnit]
              data.detailed.push
                ad_tag: adUnit
                ad_slot: 'standard'
                revenue : r["revenue"]
                impressions : r["impressions"]
                requests : r["impressions"] + (if r['passbacks'] then r['passbacks'] else 0)
                website: website
                cpm : r["cpm"]
                currency: 'USD'
            @sumDetailed data
            cb data
            return
      #in case we have no data for that day
      cb
        currency: 'USD'
        revenue: 0
        requests: 0
        impressions: 0

module.exports = Crawler : Crawler