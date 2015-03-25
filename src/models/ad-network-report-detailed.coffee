report = require '../models_base/report'
_ = require 'lodash'
# Intention of this class to store same date as ad_network_report but in details.
# So it stores data for each adv_tag / custom_channel
module.exports = (sequelize, DataTypes) ->
  baseFields = report.fields sequelize, DataTypes
  newFields =
    #saame as ad_slot really
    website: {type: DataTypes.STRING}
    ad_tag: {type: DataTypes.STRING}
    #groups of ad_tags, similar thing, just different names
    custom_channel: {type: DataTypes.STRING}
#    ad_slot: {type: DataTypes.STRING}
    #groups of ad_tags

  fields = _.merge baseFields, newFields
  sequelize.define 'AdNetworkReportDetailed',
    fields
  ,
    tableName : 'ad_network_reports_details'
    timestamps : false
    classMethods :
      associate : (models) -> @belongsTo models.AdNetworkAccount, foreignKey : 'ad_network_account_id'
      add : (data) ->
        @findOrCreate({ad_network_account_id : data.ad_network_account_id, start_date : data.start_date, end_date: data.end_date, ad_tag: data.ad_tag, custom_channel: data.custom_channel, website: data.website}, data).success (report, created) ->
          report.updateAttributes(data) if not created
          created
