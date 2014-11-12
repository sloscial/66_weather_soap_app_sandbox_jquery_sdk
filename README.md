# Developing with Grunt

Grunt is a NodeJS-based task runner.  It helps automate common tasks, such as
asset compilation, minification, and testing.  Grunt tasks are included for this
SDK in `Gruntfile.coffee`.

Follow directions below to get up and running with Grunt.

## Prerequisites

- [NodeJS](http://nodejs.org)

## Install NodeJS Modules

From the root directory of the SDK (where `Gruntfile.coffee` is
located), install NodeJS modules:

    npm install

## Build for Production

To compile assets and create a full production build, run the
build task:

    grunt build

## Development

During development, a full minified SDK build is unnecessary.  To
compile assets without minifying:

    grunt compile

## Automatic Compilation & Testing

Since it's cumbersome to manually compile assets after every change during
development, the SDK's `Gruntfile.coffee` includes a `watch` task.  The
task monitors changes to the SDK's `coffee` and `sass` assets,
automatically compiling (but not minifying) them.  Run the following command
before making changes:

    grunt watch

SDK tests are also executed by the `watch` task.  If changing the SDK
significantly, some or all tests may fail.  You may disable auto-testing by
editing the `watch` task in `Gruntfile.coffee`.

## Running Tests

The SDK comes with a complete test suite.  Execute tests from grunt:

    grunt test

Or execute tests directly in a browser.  Open `test/index.html` and click
"Run Tets".


# Using the SDK

Before using the SDK, make sure to initialize it with the server URL:

    $ ->
      AppSdk.init()
      AP.baseUrl = 'http://www.path.com/to/api'

## Working with Data

This SDK supports the following models.  For more information, see
the docs.

* `WeatherByZip`


### Working with `WeatherByZip`

Fetch data for `WeatherByZip`:

    weather_by_zips = new WeatherSoapAppSdk.collections.WeatherByZipAll
    weather_by_zips.fetch
      success: ->
        # do something

Create a new instance of `WeatherByZip`:

    weather_by_zip = new WeatherSoapAppSdk.models.WeatherByZip 

Save an instance of `WeatherByZip`:

    weather_by_zip.save()

Update an instance of `WeatherByZip`:

    weather_by_zip.set
      field_one: 'value1' # replace with actual field names and values
      field_two: 'value2'
    weather_by_zip.save()

Delete an instance of `WeatherByZip`:

    weather_by_zip.delete()



## Authentication:  Login & Logout

    AP.auth.Authentication.login
      username: 'test'
      password: 'password'
    
    AP.auth.Authentication.logout()

