# README

This is our class project for CSCE 431 503. We are _Sapphire on Subways_, and we
are creating this app as a means for the DAS (Dance Art Society) to easily
generate a schedule for their shows after auditions.

Some configurations:

* Ruby version 2.6.3p62

* System dependencies specified in Gemfile

* Configuration:
  - Use `bundle install --without production` at first. Then future builds
    can use `bundle install`.

* Database creation and initialization
  - Run `rake db:setup` and `rake db:migrate` to initialize

* How to run the test suite
  - Run __Cucumber__ from the root folder: `cucumber --guess`
  - Run __RSpec__ from the root folder: `rspec spec/<spec name>` for any spec. To run all specs, simply run `rspec spec/*`

* Deployment instructions: Credit to Dr. Michael Nowak, as these come from his tutorial
  
  `$ nvm i v8` 

  `$ npm install -g heroku`

  Make sure heroku and postgresql are installed:

  `$ heroku`

  `$ sudo yum install postgresql postgresql-server postgresql-devel postgresql-contrib postgresql-docs`

  Make sure everything is installed and login:

  `$ bundle install`

  `$ heroku login` to the project

  `$ git push heroku master`