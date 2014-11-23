# CoCuPu

UGH: https://github.com/rails/rails/pull/2948#issuecomment-5832017

## TL;DR.

```
  bundle install
  rake db:create
  rake db:migrate
  rake rails:update:bin   # see http://edgeguides.rubyonrails.org/4_0_release_notes.html#railties-notable-changes
  rails g bindery:jetty
  rake jetty:start
  rake spec
  rake bower:install      # installs javascript dependencies using bower & puts them into asset pipeline
  unicorn_rails
```

```
  rake resque:work QUEUE=reify_rows,reify_hashes,statused
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

Copy config/client_secrets.json.example to config/client_secrets.json and put in appropriate values.  
For now, just enter this as client_id: "840123515072-1ke126hupk0tml04ir9elj9a90hg2cfv.apps.googleusercontent.com"


## Workers

### In production:

We use "resque-pool":https://github.com/nevans/resque-pool in production.  See that README for more info.

`resque-pool --daemon --environment production`

### In development:

```
  rake resque:work QUEUE=*
```

# License & Copyright

DataBindery and all of its source code is property of CoCuPu LLC
© copyright CoCuPu LLC 2014. All rights reserved.
