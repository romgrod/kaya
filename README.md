Kaya
==============


#### *This gem was created in order to expose tests easily so anybody is allowed to execute them.*



  ONLY FOR UBUNTU (By Now)

  Before installing Kaya you should have installed:

  - MongoDb (version >= 2.6) See http://www.mongodb.org/downloads

    $ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
    $ sudo apt-get update
    $ sudo apt-get install mongodb
    $ sudo service mongodb start

  - Redis (http://tosbourn.com/install-latest-version-redis-ubuntu/)

    $ sudo apt-get install -y python-software-properties
    $ sudo add-apt-repository -y ppa:rwky/redis
    $ sudo apt-get update
    $ sudo apt-get install -y redis-server

  - If you want to run GUI tests using WebDriver in headless mode you should install xvfb package
    $sudo apt-get intall xvfb

  - While running in headless mode you may face an error like:
    LIBDBUSMENU-GLIB-WARNING **: Unable to get session bus: Error spawning command line `dbus-launch --autolaunch
  This coulb be solved by installing dbus-x11 package
    $apt-get install dbus-x11



## Kaya Installation

    $ gem install kaya

## Usage

Go to your project folder and run install command to use kaya over your project

    $ kaya install

Then bundle it

    $ bundle install

Configure a JSON file called kaya_conf with the values you need

    /kaya_conf

Start Kaya and follow instructions

    $ kaya start





How it works
---------------------

When you run `kaya install` command, kaya will do:

- Update your Gemfile if it exist, else will create it. Also will define gem 'kaya' on it, of course.

- Creates a folder on your root project folder with some files on it. Those files are used by kaya to work.

The file called kaya_conf has some configuration that you can/must modify ( or see at least). You should only use kaya_conf and some logs files (kaya_log & sidekiq_log)

The file config.ru has the needed code to start the service (DO NOT MODIFY IT)

After configuring kaya_conf file you are able to run `kaya start`

After starting Kaya you can go to Help section and see all what you need to know to work with kaya regarding to set up test suites, custom parameters and so.

Enjoy it!

Take it easy!


Reference about configuration

kaya/kaya_conf file reference:

    {
    "USE_GIT" : true,
    "HOSTNAME" : "your-host-name",
    "APP_PORT" : 8080,
    "DATABASE" : {
    "TYPE" : "mongodb",
    "HOST" :"localhost",
    "PORT" : 27017,
    "USERNAME" : null,
    "PASSWORD" : null},
    "PROJECT_NAME" : "Awesome Project",
    "PROJECT_URL" : "http://your.project.url",
    "INACTIVITY_TIMEOUT" : 60,
    "KILL_INACTIVE_EXECUTIONS_AFTER" : 300,
    "FORMAT_DATETIME" : "%d/%m/%Y %H:%M:%S",
    "REFRESH_TIME" : 10,
    "NOTIFICATION" : {
    "USE_GMAIL" : false,
    "USERNAME" : null,
    "PASSWORD" : null,
    "RECIPIENTS" : "your@email.com",
    "ATTACH_REPORT" : false
    },
    "FOOTER" : "Tests by a great and funny team",
    "AUTO_EXECUTION_ID" : {
    "datetime" : true,
    "format" : "%d%^b%y-%H%M",
    "default" : null
    },
    "HEADLESS" : {
    "active" : false,
    "resolution" : "1024x768",
    "size":"24"}
    }

This file is where you can configure:

  "USE_GIT": (Boolean) set as true if you are using git

  "MONGO_HOST" : (String) The host where mongodb is running

  "APP_PORT" : (Fixnum/Int) The http port that Kaya will be listening

	"PROJECT_NAME" : (String) The name of your Cucumber project

  "PROJECT_URL" : (String) The url of your project (basically the url of the repository)

  "INACTIVITY_TIMEOUT" : (Fixnum/Int) The time in seconds to consider an execution as inactive. This will show you the option to reset an inactive execution

  "KILL_INACTIVE_EXECUTIONS_AFTER" : (Fixnum/Int) The time in seconds to wait for killing automatically those inactive executions

  "FORMAT_DATETIME" : "%d/%m/%Y %H:%M:%S"

  "REFRESH_TIME" : (Fixnum/Int) The time in seconds to refresh result window in console view

  "NOTIFICATION" : (Boolean) This is a flag to use notifications through gmail service. You should have a gmail account to use it.

	"FOOTER" : (String) A text you want to see at the footer like "Tests by a great team (team_name@domain.com"

  "AUTO_EXECUTION_ID" : (JSON) If you want to use a simple execution id given by the actual time you can set the value of "datetime" to true (Boolean), with this option you can use a strftime format and it will put the execution id automatically.
  If you set "datetime" to false (Boolean) you can use "default" value. Setting "datetime" as false and "default" as null you will have to (if you need it) set the execution id manually each time you run a suite.

  "HEADLESS" (JSON) : Set active as true to use headless mode


Available Commands
---------------------

- To adapt your project to use kaya

    $ kaya install

- To start kaya service

    $ kaya start

- To clear all suites and results collection. To erase all data from database

    $ kaya reset

- To clear all suites collection only. To erase all suites data from database

    $ kaya reset_suites

- to shut down kaya

    $ kaya stop

- to restart kaya

    $ kaya restart


Get (what you need!)
---------------------

- /kaya/suites

- /kaya/suites/`<suite_name>`/run

- /kaya/results

- /kaya/results/`<suite_name>`

- /kaya/results/`<result_id>`/log

- /kaya/results/`<result_id>`

- /kaya/help


Tip
---------------------

If you shutdown kaya and then you want to get it up and the port you are using is already in use you could use the following commands (Ubunutu OS):

    $sudo netstat -tapen | grep ":8080 "

In this example we use the port 8080. This command will give you the app that is using the port. Then you could kill it getting its PID previously.


API
=======

Returns the list of suites

    kaya/api/suites

Returns the list of suites that are running

    kaya/api/suites/running

Returns the status of the given suite id

    kaya/api/suites/<suite_id>/status

Returns the suite structure for the given suite id

    kaya/api/suites/<suite_id>

Returns all existing results

    kaya/api/results

Returns the result for a given result id

    kaya/api/results/<result_id>

Returns the data you've added to result from execution

    kaya/api/results/<result_id>/data



Contributing
---------------------

1. Fork it (http://github.com/`<my-github-username>`/kaya/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
