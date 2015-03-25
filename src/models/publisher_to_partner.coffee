module.exports = (sequelize, DataTypes) ->
  sequelize.define 'PublisherToPartner',
    partner_id: {type: DataTypes.INTEGER}
    publisher_id: {type: DataTypes.INTEGER}
  ,
    tableName : 'publisher_to_partners'
    timestamps : false
