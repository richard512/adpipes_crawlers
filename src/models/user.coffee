module.exports = (sequelize, DataTypes) ->
  sequelize.define 'User',
    email: {type : DataTypes.STRING, allowNull : false}
    encrypted_password: {type : DataTypes.STRING, allowNull : false}
    reset_password_token: {type : DataTypes.STRING}
    reset_password_sent_at: {type: DataTypes.DATE}
    remember_created_at: {type: DataTypes.DATE}
    sign_in_count: {type: DataTypes.INTEGER, allowNull: false}
    current_sign_in_at: {type: DataTypes.DATE}
    last_sign_in_at: {type: DataTypes.DATE}
    current_sign_in_ip: {type: DataTypes.STRING}
    last_sign_in_ip: {type: DataTypes.STRING}
    created_at: {type: DataTypes.DATE}
    updated_at: {type: DataTypes.DATE}
    role: {type: DataTypes.STRING, allowNull : false}
    description: {type: DataTypes.STRING}
  ,
    tableName : 'users'
    timestamps : false
    classMethods :
      associate : (models) -> @hasMany models.AdNetworkAccount, foreignKey : 'user_id'
