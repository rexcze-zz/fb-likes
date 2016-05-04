# FB likes
Get lists of pages that users with given IDs like on Facebook.

## Installation
```
git clone https://github.com/kallak/fb-likes
cd fb-likes
bundle
```

## Usage
You need to have Redis installed and it should be running.
http://redis.io/download

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
bin/launch [input file]
```

The input file should contain list of user IDs with each user ID placed on separate line.

```
[user1 ID]
[user2 ID]
...
```

To get user ID you can use http://findmyfbid.com/

Retrieved data are stored into Redis and are overwritten each time the script is run. Export the data first, before you start the script again.

### Export data to TSV
```
bin/export
```

Data will be saved into file **likes.tsv**

You can export the data as many times as you want, but if you run the script to get data the data will be overwritten.
