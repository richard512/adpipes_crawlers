fs = require 'fs'
path = require 'path'
_ = require 'lodash'

files = fs.readdirSync __dirname
casperjsFiles = fs.readdirSync __dirname + '/casperjs_classes'
casperjsFiles = ('casperjs_classes/' + file for file in casperjsFiles)

casperjsFilesAppnexus = fs.readdirSync __dirname + '/casperjs_classes/appnexus'
casperjsFilesAppnexus = ('casperjs_classes/appnexus/' + file for file in casperjsFilesAppnexus)
casperjsFilesYahoo = fs.readdirSync __dirname + '/casperjs_classes/yieldmanager'
casperjsFilesYahoo = ('casperjs_classes/yieldmanager/' + file for file in casperjsFilesYahoo)
casperjsFilesEvolvemedia = fs.readdirSync __dirname + '/casperjs_classes/evolvemedia'
casperjsFilesEvolvemedia = ('casperjs_classes/evolvemedia/' + file for file in casperjsFilesEvolvemedia)
casperjsFilesGwallet = fs.readdirSync __dirname + '/casperjs_classes/gwallet'
casperjsFilesGwallet = ('casperjs_classes/gwallet/' + file for file in casperjsFilesGwallet)

files = _.union files, casperjsFiles
files = _.union files, casperjsFilesAppnexus
files = _.union files, casperjsFilesYahoo
files = _.union files, casperjsFilesEvolvemedia
files = _.union files, casperjsFilesGwallet

files.filter((file) ->
  (file.indexOf('.coffee') > 0) and (file isnt 'index.coffee')).
forEach (file) ->
  crawler = require "./#{file}"
  crawlerName = file.replace '.coffee', ''
  crawlerName = crawlerName.replace /.+\//, '' #removing folder's names
  module.exports[crawlerName] = crawler.Crawler
