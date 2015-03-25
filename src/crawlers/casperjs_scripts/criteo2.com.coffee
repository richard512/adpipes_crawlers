casper_helper = require './casper.helper'
str_parser = require './../string_parser'

x = require('casper').selectXPath

casper = casper_helper.casper
helper = casper_helper.helper

#casper.enableDebug()
params = helper.params
start_date = params.start_date.format 'DD-MM-YYYY'
end_date = params.end_date.format 'DD-MM-YYYY'


casper.start 'https://publishers.criteo.com/'
  

casper.then ->
  @sendKeys x('//*[@id=\'ctl00_MainContent_ctlLogin_ctlLogin_UserName\']'), params.username
  @sendKeys x('//*[@id=\'ctl00_MainContent_ctlLogin_ctlLogin_Password\']'), params.password
  @click x('//*[@id=\'ctl00_MainContent_ctlLogin_ctlLogin_LoginBtn_InnerSpan\']')


casper.waitForSelector x("//*[@id='ctl00_ctl00_ctl00_MainContent_ctlMenu']/ul/li[3]/a"), ->
  casper.click x("//*[@id='ctl00_ctl00_ctl00_MainContent_ctlMenu']/ul/li[3]/a")
  
casper.waitForSelector x('//*[@id=\'ctl00_ctl00_ctl00_MainContent_PublisherContent_PageContent_ctlStatsMgr_ddlPeriods\']'), ->
  casper.click x('//*[@id=\'ctl00_ctl00_ctl00_MainContent_PublisherContent_PageContent_ctlStatsMgr_ddlPeriods\']')
  @waitUntilVisible x("//*[@id='ctl00_ctl00_ctl00_MainContent_PublisherContent_PageContent_ctlStatsMgr_ddlPeriods']/option[10]"), ->
    casper.click x("//*[@id='ctl00_ctl00_ctl00_MainContent_PublisherContent_PageContent_ctlStatsMgr_ddlPeriods']/option[10]")
   
casper.then ->
  @sendKeys x('//*[@id=\'ctl00_ctl00_ctl00_MainContent_PublisherContent_PageContent_ctlStatsMgr_tbBeginDate\']'), start_date, reset: true
  @sendKeys x('.//*[@id=\'ctl00_ctl00_ctl00_MainContent_PublisherContent_PageContent_ctlStatsMgr_tbEndDate\']'), end_date, reset: true
  @click x('//*[@id=\'ctl00_ctl00_ctl00_MainContent_PublisherContent_PageContent_ctlStatsMgr_ctlExecute_InnerSpan\']')

casper.then ->
  @waitForSelector 'tfoot tr td', ->
    data =
      requests: str_parser.toInt(@fetchText('tfoot tr td:nth-child(8)'))
      cpm: str_parser.toFloat(@fetchText('tfoot tr td:nth-child(6)'))
      revenue: str_parser.toFloat(@fetchText('tfoot tr td:nth-child(7)'))
      impressions: str_parser.toInt(@fetchText('tfoot tr td:nth-child(3)'))
      ctr: str_parser.toFloat(@fetchText('tfoot tr td:nth-child(5)'))
      currency: 'USD'

    helper.returnData data

casper.run()
