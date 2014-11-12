The AnyPresence HTML5 SDK is the `M`, or model, in an JavaScript `MVC` app.  The SDK simplifies working with data retrieval and manipulation, auth management, and provides a number of useful utilities.  It may be paired with many UI frameworks, making it an excellent choice for flexible and convenient development.  When building a custom UI from scratch, choose a framework that can coexist with jQuery and Backbone.js.


## Compatibility

Your generated SDK comes in two flavors:  CoffeeScript and JavaScript.  We recommend developing in CoffeeScript and compiling to JavaScript for deployment.  Some environments, such as Rails, allow for on-the-fly compilation.  The language and compilation strategy you choose is entirely up to you.


## Prerequisites

Be sure to choose the appropriate SDK file for your platform:  one of `ap_sdk.coffee` or `ap_sdk.js`.  The SDK requires jQuery, Underscore.js, and Backbone.js.  Include these on the page before the SDK.


## Initialization

The SDK must be initialized before use.  For example, to initialize the SDK after page load:

    $ ->
      AppSdk.init()
      AP.baseUrl = 'http://www.path.com/to/api'

Once initialized, you can jump right in and use [models](#!/guide/working_with_models), [collections](#!/guide/working_with_collections), and the [auth](#!/guide/authentication_and_authorization).

## More Information
More information is available in both the SDK and BackboneJS documentation.  Since the HTML5 SDK models and collections inherit from BackboneJS, usage syntax is exactly the same.  If you have additional questions, please contact your AnyPresence support person.

