casper_helper = require './casper.helper'
str_parser = require './../string_parser'

casper = casper_helper.casper
helper = casper_helper.helper
params = helper.params
#casper.enableDebug()

#for testing set start date : "Dec 18,2010"

casper.options.timeout = 50000

report_id = ""


casper.start 'https://my.lifestreetmedia.com/login/', ->
  @fillSelectors 'form.loginForm',
    'input[name="username"]' : params.username
    'input[name="password"]' : params.password
  , true



casper.wait 20000, ->
  casper.capture 'test222.png'


casper.waitForSelector ".apps_sites", ->

  console.log params.start_date.format "MMM DD, YYYY"
  console.log params.end_date.format "MMM DD, YYYY"


  sd = params.start_date.format "MMM DD, YYYY"
  #for testing set start date : 
  #sd = "Dec 18,2010"
  ed = params.end_date.format "MMM DD, YYYY"
  formData = 
    type              : "grid"
    name              : "aaa111aaa"
    date_range        : "custom"
    from_Date         : sd
    from_Hour         : ""
    end_date_type     : "static"
    to_Date           : ed
    to_Hour           : ""
    "dimensions[]"    : ["Hour"]
    dimension         : "Hour"
    "measurements[]"  : ["adCost","adImps","rpm"]
    save              : "Save"
  

  casper.thenOpen "http://my.lifestreetmedia.com/rep/add/", {method: "POST", data: formData}, =>
    delete formData["save"]
    formData["run"] = "Run (don't save)"
    id = this.evaluate (()=>
      $('#all tbody tr td a[title="aaa111aaa"]').prop("href") )
    report_id = id.replace /http:\/\/my\.lifestreetmedia\.com\/rep\/result\// , ""
    
  

  casper.wait 20000, ->
  casper.capture 'test2qwqwqw22.png'

  casper.thenOpen "http://my.lifestreetmedia.com/rep/edit/#{report_id}", {method: "POST", data: formData}, =>
    formData =
      test_id : "temporary_test_prefix_#{report_id}"
    casper.thenOpen "http://my.lifestreetmedia.com/ajax/getTestF", {method: "POST", data:formData},=>
      content = this.getPageContent()

      get = (number) =>
        this.fetchText ".tablesorter tfoot tr th:nth-of-type(#{number})"

      if !casper.exists('.tablesorter') 
        console.log "this date is not available"
      else
        data = 
          revenue     : get 2
          impressions : get 3
          currency    : 'USD'
          json        : {"rpm" : get 4}
        helper.returnData data
    
      casper.thenOpen "http://my.lifestreetmedia.com/rep/delete/#{report_id}", {method: "GET"}
 
casper.run()
