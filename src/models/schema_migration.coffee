module.exports = (sequelize, DataTypes) ->
  sequelize.define 'SchemaMigration',
    version: {type : DataTypes.STRING, allowNull : false}
  ,
    tableName : 'schema_migrations'
    timestamps : false