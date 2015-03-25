report = require '../models_base/report'
_ = require 'lodash'

module.exports = (sequelize, DataTypes) ->
  baseFields = report.fields sequelize, DataTypes
  newFields  =
    website: {type: DataTypes.STRING}
  fields = _.merge baseFields, newFields
  sequelize.define 'AdNetworkReportWebsite',
    fields
  ,
    tableName : 'ad_network_report_websites'
    timestamps : false
    classMethods :
      associate : (models) -> @belongsTo models.AdNetworkAccount, foreignKey : 'ad_network_account_id'
      add : (data, cb) ->
        @findOrCreate({ad_network_account_id : data.ad_network_account_id, start_date : data.start_date, end_date: data.end_date, website: data.website}, data).success (report, created) ->
          report.updateAttributes(data) if not created
          created
