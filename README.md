INSTALLATION
============

Requirements
------------
* PostgreSQL
(You also can use `phppgadmin` to view tables via web browser).
* Node.js

How to install
---------------------
* Clone the project to your git folder. `git clone https://github.com/teamff/adpipes_crawlers.git`
* In folder run `npm install` to get all dependents.
* Create settings file: `cp src/config.coffee.example src/config.coffee`. Into the file you need to change fields db, username and password using data access from your PostgreSQL database.
* run `gulp dbSync` to load db Scheme

Adding crawlers
---------------------
* You need add crawler's name and credentials into `ad_networks` table. Fields to add: crawler's name (names should the same as are names for crawlers `.coffee` files without extension), username, password. When you are in crawler's database, use command
`INSERT INTO ad_networks VALUES (0,'lijit.com','lijit.com', true);`
`INSERT INTO ad_network_accounts VALUES(0, 'affiliateballsie', 'Adsales!4', '', '', '', true, 0, 0);`
* Now you can use crawler lijit.com. Add more records into table to use more crawlers.

USING
============

To run crawler scripts use command `gulp run`. Without parameters this command runs all crawlers which you have in `ad_networks` table and makes report for yesterday.

Running single crawler
----------------------
Use parameter `--name` to set name of crawler which you want to run. It is a single entry in your `ad_networks` table.
* type e.g. `gulp run --name lijic.com` or `gulp run --name openx` or another.

Running date ranges
-------------------
All date arguments except `--hours` use servise's timezone.
* `gulp run --name openx` (no date parameters) report for yesterday
* `gulp run --name openx --daysAgo 3` report for day (24 hours) which was 3 days ago. `--daysAgo 1` - same as default (report for yesterday)
* `gulp run --name openx --days 3` report for last 3 days (yesterday and 2 days before) `--days 1` - same as default (report for yesterday) and same as `--daysAgo 1`
* `gulp run --name openx --startDate 2014-02-28` report for the date `2014-02-27` (00:00 - 23:59) 
* `gulp run --name openx --startDate 2014-02-10 --endDate 2014-02-20` report for the day range since about `2014-02-10` to `2014-02-20`
* `gulp run --hours 3` report for last three full hours.

Also there is option to request data for few days at once. But Crawlers are not required to support few days at once.   
So some crawlers will show wrong response, in most cases data will be just for first or for last day.  


Crawlers requirements
---------------------
[Crawlers](docs/crawlers.md)

[Requirements-ru](docs/requirements-ru.md)
Testing crawlers
---------------
* `gulp spec` - all enabled crawlers (only first credentials for selected adv network will be used)
* `gulp spec --name koomona` -only one crawler 
* `gulp spec --name koomona --startDate 2014-02-28` - tests will run for 2014-02-27 and 2014-02-26 in most cases (depends on timezone)


ATTENTION! GOOGLE Accounts
--------------------------
In order to be able to go ANYWHERE near the Google accounts (AdExchange, DFP, AdSense etc) you will need to use 
proxy or vpn. You should ask for credentials. 

Issue with phantomjs
--------------------
If you have error **phantomjs is not found** type this in shell (use your project path instead of 
`/www/ad-network-crawlers`):     
`export PATH=$PATH:/www/ad-network-crawlers/node_modules/phantomjs/bin`
