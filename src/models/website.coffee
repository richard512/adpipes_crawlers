module.exports = (sequelize, DataTypes) ->
  sequelize.define 'Website',
    ad_network_account_id : {type : DataTypes.INTEGER, allowNull : false}
    website : {type : DataTypes.STRING, allowNull : false}
    enabled : {type : DataTypes.BOOLEAN, allowNull: false, defaultValue: true}

  ,
    tableName : 'websites'
    timestamps : false
    classMethods :
      associate : (models) -> (models) -> @belongsTo models.AdNetworkAccount, foreignKey : 'ad_network_account_id'
