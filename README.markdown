govpulse
========

The Federal Register at your fingertips.
 
http://govpulse.us

* The source code is available on Github at [http://github.com/trifecta/govpulse](http://github.com/trifecta/govpulse).
* Code bugs can be filed at Lighthouse, via [http://govpulse.lighthouseapp.com/projects/35087-govpulseus/overview](http://govpulse.lighthouseapp.com/projects/35087-govpulseus/overview).
* Problems, suggestions, etc can also be filed at Tender, via [http://govpulse.tenderapp.com/discussions](http://govpulse.tenderapp.com/discussions)

About
------------

This project was created for the Apps for America 2 contest and as a way for us to use our talents to help others participate in their government.

When we embarked on the creation of this site in our spare time, 3 weeks before the Apps for America 2 deadline, we knew that the open source software community would be essential to us realizing our dream. We are deeply indebted to all those who toil everyday to create incredible software and freely share it with the world. We are proud to have toiled along side them and thankful for their efforts to enable us to build a new app and tools we can release back into the community. It is our hope that this app continues to celebrate that spirit and gives back to that community, to the people of the US, and the world.

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