report = require '../models_base/report'
_ = require 'lodash'

module.exports = (sequelize, DataTypes) ->
  sequelize.define 'AdNetworkReport',
    report.fields(sequelize, DataTypes)
  ,
    tableName : 'ad_network_reports'
    timestamps : false
    classMethods :
      associate : (models) -> @belongsTo models.AdNetworkAccount, foreignKey : 'ad_network_account_id'
      add : (data) ->
        @findOrCreate({ad_network_account_id : data.ad_network_account_id, start_date : data.start_date, end_date: data.end_date}, data).success (report, created) ->
          report.updateAttributes(data) if not created
          created
