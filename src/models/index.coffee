fs = require 'fs'
path = require 'path'
Sequelize = require 'sequelize'
config = require '../config'

sequelize = new Sequelize config.db, config.username, config.password, dialect : 'postgres', port : config.port, host: config.host, omitNull: true

module.exports = sequelize : sequelize, Sequelize : Sequelize

fs.readdirSync(__dirname).filter((file) -> (file.indexOf('.') isnt 0) and (file isnt 'index.coffee')).forEach (file) ->
  model = sequelize.import(path.join(__dirname, file))
  module.exports[model.name] = model

for name, model of module.exports when name isnt 'sequelize' or name isnt 'Sequelize'
  model.associate? module.exports
