global.chai = require 'chai'
global.should = chai.should()
global.sinon = require 'sinon'
global.sinonChai = require 'sinon-chai'
chai.use sinonChai
