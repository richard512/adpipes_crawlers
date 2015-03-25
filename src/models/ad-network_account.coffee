module.exports = (sequelize, DataTypes) ->
  sequelize.define 'AdNetworkAccount',
#    ad_network_id: {type: DataTypes.STRING, allowNull: false}
    username: {type: DataTypes.STRING, allowNull: false}
    password: {type: DataTypes.STRING, allowNull: false}
    token: {type: DataTypes.STRING}
    secret: {type: DataTypes.STRING}
    refresh_token: {type: DataTypes.STRING}
    enabled: {type: DataTypes.BOOLEAN, allowNull: false, defaultValue: true}
  ,
    tableName: 'ad_network_accounts'
    timestamps: false
    classMethods:
      associate: (models) -> @belongsTo models.AdNetwork, foreignKey: 'ad_network_id'
      fill: ->
        login = require('../config.coffee').GOOGLE_AUTH
        AdNetwork = require('./').AdNetwork
        Spreadsheet = require 'edit-google-spreadsheet'
        SPREADSHEET_KEY = '1q4JV5GEuHQQIQ3t7W4iOXOqA-WsCiS3uS5giwoIImlw'
        Spreadsheet.load
          debug: true
          spreadsheetId: SPREADSHEET_KEY
          worksheetName: 'Verified logins'
          username: login.email
          password: login.password
          (err, spreadsheet) =>
            console.log err if err
            spreadsheet.receive (err, rows, info) =>
              console.log err if err
              @destroy({}, truncate: true, force: true).then =>
                for index, row of rows
                  if index > 1
                    do (row) =>
                      AdNetwork
                        .find {where: {name: row[7]}}
                        .then (adNetwork) =>
                          if adNetwork
                            temp = {}
                            temp['username'] = row[1]
                            temp['password'] = row[2]
                            temp['token'] = row[3] || null
                            temp['secret'] = row[4] || null
                            temp['refresh_token'] = row[5] || null
                            temp['enabled'] = row[6] || null
                            temp['ad_network_id'] = adNetwork.values.id
                            @create temp