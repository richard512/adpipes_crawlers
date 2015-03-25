base = require './base'
str_parser = require './string_parser'
class Crawler extends base.Base

  loginURL: 'https://n13.epom.com/j_spring_security_check.do'

  timezone: 'America/New_York'
  onlyDaily: true
  @website: false

  init:->
    @timezonePrepare()
    @loginForm =
      j_username: @username
      j_password: @password

  process : (err, resp, body, cb) ->
    @reportURL = "https://n13.epom.com/account/publishers/dashboard/tree.do?_dc=1419365649520&rangeType=YESTERDAY&sort=%5B%7B%22property%22%3A%22leaf%22%2C%22direction%22%3A%22ASC%22%7D%5D&node=root"
    @request @reportURL, {'method' : 'GET'}, (err, resp, body) =>
      @extract body, cb, err, resp

  extract: (body, cb, err, resp) ->
    if body.indexOf("<!DOCTYPE html>") isnt -1 and body.indexOf("password") isnt -1
      #throw new Error "Authorization failed of user #{@username}"
      errorData =
        id: @errorDbId
        status: "breaked by login"
        error_id: 2
      models.AdNetworkError.edit errorData
    else 
      try
        json = JSON.parse resp.body
        reportData =
          impressions : json[0].data.impressions
          clicks : json[0].data.clicks
          requests : json[0].data.requests
          cpm : json[0].data.ecpm
          ctr : json[0].data.ctr
          fill_rate : json[0].data.fillRate
          revenue : json[0].data.revenue
          currency: 'USD'
          json : json[0].data
      catch e
        reportData =
          revenue: 0
          requests: 0
          impressions: 0
          currency: "USD"
      cb reportData

module.exports =
  Crawler: Crawler
