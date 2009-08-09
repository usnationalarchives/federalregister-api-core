govpulse
========

The Federal Register at your fingertips.
 
http://govpulse.us

Installation
------------

First, you'll need Ruby, Rails 2.3.3, the Sphinx search engine, MySQL, and the ruby MySQL bindings.

    git clone git://github.com/trifecta/govpulse.git
    cd govpulse
    git submodule init
    git submodule update
    
Then you'll need to create the config/database.yml and config/api_keys.yml files, based on the examples.

Then:

    [sudo] rake gems:install
    rake db:create
    rake db:migrate

To fetch data, you'll need to run the following tasks

    rake data:download:entries
    rake data:download:full_text
    rake data:extract:agencies
    rake thinking_sphinx:index

To start up the application, simply run

   script/server

Contact us at govpulse@gmail.com if you run into any trouble; we'll revise these instructions as necessary to make it easy.

License
-------

govpulse is released under the Affero GPL v3, which requires that the source code be made available to any network user of the application. So while we encourage you to fork and run your own copies of this application, any changes you make need to be shared with their users.  Note that this does not allow the use of the govpulse name or logo.

govpulse itself is copyrighted by David Augustine, Robert Burbach, and Andrew Carpenter.

A variety of external libraries are included with this software; they are all open source, and with one exception are suitable for use in any way.  