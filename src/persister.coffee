models = require './models'
crawlers = require './crawlers'
_ = require 'lodash'
moment = require 'moment'
Mailgun = require('mailgun').Mailgun
mg = new Mailgun 'key-be9ae4f2753a614cb60bd1d395aa6a48'
Promise = require 'bluebird'

class Persister
  #start_date / end_date are moment dates
  @run: (time_type, start_date, end_date, @cb, conditions = {}) ->
    _.merge(conditions, { where: {enabled: true, ad_network_id: {ne: null}}})
    params =
      time_type: time_type
      start_date: start_date
      end_date: end_date
      conditions: conditions
      id: null

    @runAsync(params).then (value) ->
      console.log '[ALL CRAWLERS HAS BEEN FINISHED]'
    .catch (e)->
      console.log 'Exception has been caught'
      console.log e.message
      console.log e.stack
      mg.sendText 'errors@adpipes.io', 
        ['tools.adpipes@gmail.com'], 
        e.message + '\n' + e.stack,
        (err) ->
          console.log err if err

  @runAsync: (params) ->
    models.AdNetworkAccount.findAll(params.conditions).then (adNetworksAccounts) ->
      adNetworkPromises = (Persister.runSingleAsync adNetworkAccount, params for adNetworkAccount in adNetworksAccounts)
      Promise.all adNetworkPromises

  @runSingleAsync: (adNetworkAccount, params) ->
    adNetworkAccount.getAdNetwork()
    .then (adNetwork)->
      try
        throw e = new Error "AdNetwork is not exist for adNetworkAccount: #{adNetworkAccount.id}" if not adNetwork
        filename = adNetwork.filename.toLowerCase()
        throw e = new Error "#{filename} class doesn't exists" unless crawlers[filename]
        new Promise (resolve, reject)->
          models.AdNetworkError.findLast adNetworkAccount.id, (record) ->
            if record==null || moment().subtract(1, 'days') > moment(record.date) or true
              data =
                ad_network_account_id: adNetworkAccount.id
                date: moment().format("YYYY-MM-DD HH:mm")
              models.AdNetworkError.add data, (record) ->
                params.id = record.id
                adNetworkAccount.errorRowId=record.id
                resolve crawlers[filename]
      catch
        console.log e
        errorData =
          id: adNetworkAccount.errorRowId
          status: "unknown_error"+e
          error_id: 2
        models.AdNetworkError.edit errorData
        return
    .then (Crawler)->
      try
        crawler = new Crawler params.time_type, adNetworkAccount.values, params.start_date, params.end_date, params.id
        new Promise (resolve, reject)->
          crawler.publicRun (data)->
            resolve data
      catch
        return
    .then (data) ->
      if data == undefined
        data = null
      Persister.saveData adNetworkAccount, data

  @saveData: (adNetworkAccount, data)->
    if data == null
      errorData =
        id: adNetworkAccount.errorRowId
        status: "empty data"
        error_id: 2
      models.AdNetworkError.edit errorData
      return

    if data.revenue == null or data.requests == null or data.impressions == null or data.clicks == null
      errorData =
        id: adNetworkAccount.errorRowId
        status: "empty field"
        error_id: 2
      models.AdNetworkError.edit errorData
      return

    if adNetworkAccount.id == null
      errorData =
        id: adNetworkAccount.errorRowId
        status: "empty accId"
        error_id: 2
      models.AdNetworkError.edit errorData
      return

    data['ad_network_account_id'] = adNetworkAccount.id
    queries = []
    detailedInfoExists = false
    website_data = {}
    if data['detailed']
      for row in data['detailed']
        row['ad_network_account_id'] = adNetworkAccount.id
        queries.push models.AdNetworkReportDetailed.add row
        if row.website
          detailedInfoExists = true
          if website_data[row.website]
            website_data[row.website].revenue     += row.revenue
            website_data[row.website].requests    += row.requests
            website_data[row.website].impressions += row.impressions
            website_data[row.website].clicks      += row.clicks
            website_data[row.website].ctr          = 0
            website_data[row.website].cpm          = 0
            website_data[row.website].cpc          = 0
          else
            website_data[row.website] = row
      
    queries.push models.AdNetworkReport.add data
    errorData =
      id: adNetworkAccount.errorRowId
      status: "finished"
      error_id: 1
    queries.push models.AdNetworkError.edit errorData
    if detailedInfoExists
      for key, value of website_data
        queries.push models.AdNetworkReportWebsite.add website_data[key]
    else
      data.website = 'default'
      queries.push models.AdNetworkReportWebsite.add data
    Promise.all queries

#  prepareCrawler: () ->
#    persister = @
#    #if last error row for site is older than 1 hour, create new row and run crawler
#    models.AdNetworkError.findLast {where: {ad_network_id: @adNetwork.id}}, (record) ->
#      if moment().subtract(1, 'hours') > moment(record.date)
#        data =
#          ad_network_id: persister.adNetwork.id
#          date: moment().format("YYYY-MM-DD HH:mm")
#        models.AdNetworkError.add data, (record) ->
#          persister.adNetwork.errorDbId = record.id
#          persister.crawler = new crawlers[persister.adNetwork.name.toLowerCase()] persister.time_type, persister.adNetwork.values, persister.start_date, persister.end_date, record.id
#          persister.run persister.multi_cb
#
#  persist: (data, cb) ->
#    errorData =
#      id: @adNetwork.errorDbId
#      status: "finished"
#      error_id: 1
#    if not data
#      models.AdNetworkError.edit errorData
#      return
#
#    errorData.error_id = 0
#    models.AdNetworkError.edit errorData

module.exports = Persister
