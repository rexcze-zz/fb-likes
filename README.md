# FB data
Get lists of pages that users with given IDs like or groups that they are members of.

## Installation
```
git clone https://github.com/kallak/fb-likes
cd fb-likes
bundle
```

## Usage
You need to have Redis installed and it should be running.
http://redis.io/download

Start redis-server using command (surprise surprise)
```
redis-server
```

### Run Sidekiq
```
bin/sidekiq
```

### Run Sidekiq web interface
```
rackup
```

The web inteface is by default available at URL: http://localhost:9292

### Get data
```
bin/scrape -i [input file] -t [data type: likes | groups]
bin/scrape -i [input file] -t likes
bin/scrape -i [input file] -t groups
```

To show help information run:
```
bin/scrape --help
```

The input file should contain list of user IDs with each user ID placed on separate line.

```
[user1 ID]
[user2 ID]
...
```

#### No limit
By default the number of scraped records on 1 page is limited. If you want to scrape all data, use **--nolimit** parameter.
```
bin/scrape -i [input file] -t likes --nolimit
```

#### Job timeout
Scraping data from page with lot of results can be very time consuming. If you want to interrupt the scraping job, you can define the period by using **--timeout** parameter. The default value is 600 seconds, so the scraping job will be interrupted if it runs longer than 10 minutes. If **--nolimit** parameter is used then the default timeout is set to 150 minutes.
```
bin/scrape -i [input file] -t likes --timeout=3600
```

#### Get user ID
To get user ID you can use http://findmyfbid.com/

Retrieved data are stored into Redis and are overwritten each time the script is run with the same type parameter. Export the data first, before you start the script again.

### Export data to TSV
```
bin/export [data type: likes | groups]
bin/export likes
bin/export groups
```

Data will be saved into file **likes.tsv** or **groups.tsv** according to the required data type.

You can export the data as many times as you want, but if you run the script to get data the data will be overwritten.
