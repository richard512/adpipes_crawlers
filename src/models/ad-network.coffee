module.exports = (sequelize, DataTypes) ->
  sequelize.define 'AdNetwork',
    name : {type : DataTypes.STRING, allowNull : false}
    filename : {type : DataTypes.STRING, allowNull : false}
    hasWebsite: {type : DataTypes.BOOLEAN, allowNull : false, defaultValue: false}
  ,
    tableName : 'ad_networks'
    timestamps : false
    classMethods :
      associate : (models) -> @hasMany models.AdNetworkAccount, foreignKey : 'ad_network_id'
      fill: ->
        path = require 'path'
        walk = require 'walk'
        CRAWLERS_DIR = path.join __dirname, '..', 'crawlers'
        walker = walk.walk CRAWLERS_DIR, 
          followLinks: false 
          filters: ['casperjs_scripts']
        exclusions = ['base.coffee', 'index.coffee', 'string_parser.coffee', 'casperjs.base.coffee', 'casper.helper.coffee']
        adNetworks = []
        walker.on 'file', (root, fileStats, next) ->
          if exclusions.indexOf(fileStats.name) is -1
            tempAdNetwork = {}
            adNetworkDirtyName = fileStats.name
            adNetworkName = adNetworkDirtyName.split('.')[0]
            tempAdNetwork.name = adNetworkName.charAt(0).toUpperCase() + adNetworkName.slice(1)
            tempAdNetwork.filename = adNetworkDirtyName.split('.coffee')[0]
            tempAdNetwork.hasWebsite = require(path.join root, adNetworkDirtyName).Crawler.website
            adNetworks.push tempAdNetwork
          next()

        walker.on 'end', =>
          @destroy({}, {truncate: true}).then =>
            @bulkCreate(adNetworks, {fields: Object.keys(adNetworks[0])})
