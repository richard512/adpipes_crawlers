module.exports = (sequelize, DataTypes) ->
  sequelize.define 'AdNetworkError',
    ad_network_account_id: {type: DataTypes.INTEGER, allowNull: false}
    date: {type: DataTypes.DATE, allowNull: false}
    status: {type: DataTypes.STRING, allowNull: false, defaultValue: "started"}
    error_id: {type: DataTypes.INTEGER, allowNull: false, defaultValue: 0}
  ,
    tableName: 'ad_network_errors'
    timestamps: false
    classMethods:
      associate: (models) ->
        @belongsTo models.AdNetworkAccount, foreignKey: 'ad_network_account_id'
      add: (data, cb) ->
        @findOrCreate({ad_network_account_id: data.ad_network_account_id, date: data.date},
          data).then (report, created) ->
            report.updateAttributes(data) if not created
            cb report, created
      edit: (data, cb) ->
        @find(data.id).success (report, created) ->
          if report and data.error_id>report.error_id
            report.updateAttributes(data)
          
    #cb report, created
      findLast: (ad_network_account_id, onSuccess) ->
        conditions =
          order: 'id DESC'
          where:
            ad_network_account_id: ad_network_account_id
        @find(conditions).success (record)->
          onSuccess(record) #todo not tested yet


