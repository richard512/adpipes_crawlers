module.exports = (sequelize, DataTypes) ->
  sequelize.define 'ApiKey',
    key: {type : DataTypes.STRING, allowNull : false}
    user_id: {type: DataTypes.INTEGER, allowNull : false}
  ,
    tableName : 'api_keys'
    timestamps : false