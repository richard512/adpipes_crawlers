CRAWLERS
============

###General requirements:
We need to fetch data at least hourly  where possible.  
The reason for that is that we need to have some artificial intelligence to process report's data lately.  
If possible you should do a crawler to be able to crawl from any `@requested_start_date` to any `@requested_end_date`.

If only possible to fetch data on daily base you should use "America/Los_Angeles" timezone where possible.  
In most cases that is impossible, so you should state which timezone Adv Network is using.

Example
-------
Use **[adsense.api](../src/crawlers/adsense.api.coffee)** as example for daily fetching

@requested_start_date / @start_date
-----------------------------------
That is not important if you can fetch hourly data.  

But if you can fetch only one or few days you should consider timezone. 
E.g. start date of your computer / server is : `2014-10-29 00:00:00+05`  
But for report real start of day will be: `2014-10-28 12:00:00+05`  
Just use **adsense.api** example to automatically calculate `start_date` && `end_date` for Adv Network in the `[init]` 
method.

Columns in `ad_network_reports` table:
-------------------------------------
###Mandatory:  
* start_date (you should provide exact start of a day, considering timezone for adv network, for daily report)
* end_date
* timezone ("America/Los_Angeles" preferred. [List of timezones](http://en.wikipedia.org/wiki/List_of_tz_database_time_zones)). Acronyms `GMT` && `PST` can be used as well.
* revenue
* currency (use `USD` instead of `$`)
* requests (that is total requests for adv - also called `total_impressions` in some adv networks)
* impressions (same as `paid_impressions` in some adv networks, `fill_rate = impressions/requests`). 
*Impressions* less or equal to *requests*.

In many cases you simply have one `impression` field and no `fill_rate` field.  
So adv network assume that they always have 100% `fill_rate`, so `impressions` and `requests` are equal. 
 So store that `impressions` in both `impressions` and `requests`.

###Additional fields:
* cpc 
* clicks
* ad_unit
* ad_slot
* json - store all possible data here in json format. In case we will use it in future.

###Calculated
Fields which are not necessary to fill out (will be calculated automatically).  
But anyway better to fill them, if they are provided:  

* CPM = `1000 * revenue / requests`
* fill_rate = `impressions / requests` (so can be from `0.0` to `1.0`)
* ctr =  `clicks/impressions` (so can be from `0.0` to `1.0`)

###Deprecated: 
* date 
* eCPM (it is the same as CPM, just mean calculated field from CPC / CPA and etc)

