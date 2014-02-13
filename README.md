# CoCuPu

UGH: https://github.com/rails/rails/pull/2948#issuecomment-5832017

## TL;DR.

```
  rake db:create
  rake db:migrate
  rails g bindery:jetty
  rake jetty:start
  rake spec
  rake bower:install
  unicorn_rails
```

```
  rake resque:work QUEUE=*
```

## Dependencies

* postgres
* redis & resque
* jetty
* node & bower (for managing javascript dependencies)

Only necessary for production system:
* mpg321 and vorbis-tools

### Installing Jetty

To install jetty run the generator:  
`rails g bindery:jetty`

Might be necessary:
```
$ cp contrib/analysis-extras/lib/icu4j-4_8_1_1.jar lib/
$ cp contrib/analysis-extras/lucene-libs/*.jar lib/
$ cp contrib/velocity/lib/*.jar lib/
```

### Linux-specific notes for Prod server

1. Install a javascript runtime (already installed on the Mac)
  See https://github.com/sstephenson/execjs
  I tried this one:  
  `gem install therubyracer`

1. Install mp3 to ogg transcoding stuff:  
  `sudo apt-get install mpg321 vorbis-tools`

## Running Server

`unicorn_rails`

Copy config/client_secrets.json.example to config/client_secrets.json and put in appropriate values.  Get the values from here: https://code.google.com/apis/console/b/3/?pli=1#project:840123515072:access


## Workers

### In production:

We use "resque-pool":https://github.com/nevans/resque-pool in production.  See that README for more info.

`resque-pool --daemon --environment production`

### In development:

```
  rake resque:work QUEUE=*
```


