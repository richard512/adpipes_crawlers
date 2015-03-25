sequelize = require 'sequelize'
models = require '../src/models'
crawlers = require '../src/crawlers'
_ = require 'lodash'
moment = require 'moment'
colors = require 'colors'
require './helper'
persister = require '../src/persister'
Mocha = require 'mocha'
Test = Mocha.Test
Suite = Mocha.Suite
NETWORK_TIMEOUT = 50000
NETWORK_SLOW = 30000
argv = require('minimist')(process.argv[2..]);

describe 'Crawlers', ->
  adNetworks = []
  if argv.startDate
    start_date = moment(argv.startDate).startOf('day')
  else
    start_date = moment().subtract(1, 'days').startOf('day')

  end_date = start_date.clone().endOf('day')
  previous_start_date =  start_date.clone().subtract(1, 'days').startOf('day')
  previous_end_date = previous_start_date.clone().endOf('day')

  before (done) ->
    #ONLY ONE ACCOUNT FOR ADV NETWORK START
    conditions =
      attributes: [
        sequelize.fn('min', sequelize.col('id')),
        'name'
      ]
      group: 'name'
      where:
        enabled: true
    conditions.where.name = argv.name if argv.name
    models.AdNetwork.findAll(conditions).success (values) ->
      ids = values.map (value)->
        value.dataValues.min
      conditions =
        where:
          id: ids

      models.AdNetwork.findAll(conditions).success (values) ->
        adNetworks = values
        console.log 'Total adNetworks to test: '.green, adNetworks.length.toString().green
        done()
  #ONLY ONE ACCOUNT FOR ADV NETWORK END

  it 'should be at least 1 adv network enabled', ->
    adNetworks.length.should.be.least 1

  it 'creating & executing dynamically suites', (done) ->
    #we have 2 days to check for every adv network
    this.timeout 2 * NETWORK_TIMEOUT * (adNetworks.length + 1)
    this.slow 2 * NETWORK_SLOW * (adNetworks.length + 1)
    networkSuites(done)

  networkSuites = (crawlersDone) ->
    adNetworkNumber = 0
    #    adNetworks = adNetworks[1..5]
    testNextAdNetwork = ->
      if adNetworkNumber >= adNetworks.length
        return crawlersDone()
      #else let's test next adNetwork
      adNetwork = adNetworks[adNetworkNumber++]
      mocha = new Mocha

      data = null

      suite = Suite.create mocha.suite, adNetwork.name
      suite.addTest new Test 'should return data', (done) ->
        this.timeout NETWORK_TIMEOUT
        this.slow NETWORK_SLOW
        console.log '  ', 'username', adNetwork.username.green
        crawler = new crawlers[adNetwork.name] 'remote', adNetwork.values, start_date, end_date
        crawler.publicRun (dataResponse) =>
          data = dataResponse
          should.exist data
          done()

      suite.addTest new Test 'should return requests', ->
        data.should.have.property 'requests'
        console.log 'Requests number is equal to 0 (account is idle)'.yellow unless data.requests
      suite.addTest new Test 'should return impressions', ->
        data.should.have.property 'impressions'
      suite.addTest new Test 'should return revenue', ->
        data.should.have.property 'revenue'
      suite.addTest new Test 'should have requests>=impressions', ->
        (+data.impressions).should.be.most data.requests
      suite.addTest new Test 'should have fill_rate less or equal to 1 if fill_rate is stated', ->
        data.fill_rate.should.be.most 1 if data.hasOwnProperty 'fill_rate'

      #data for day before data#
      dataBefore = null
      suite.addTest new Test 'should return data for another one day', (done) ->
        this.timeout NETWORK_TIMEOUT
        this.slow NETWORK_SLOW
        crawler = new crawlers[adNetwork.name] 'remote', adNetwork.values, previous_start_date, previous_end_date
        crawler.publicRun (dataResponse) =>
          dataBefore = dataResponse
          should.exist dataBefore
          done()

      suite.addTest new Test 'Different days should have different number of requests', ->
        data.requests.should.not.be.equal dataBefore.requests if data.requests

      mocha.run ()->
        testNextAdNetwork()

    testNextAdNetwork()


