YUI.add("yuidoc-meta", function(Y) {
   Y.YUIDoc = { meta: {
    "classes": [
        "AggregateCollection",
        "Application",
        "Authentication",
        "Authorization",
        "Base64",
        "BelongsTo",
        "Collection",
        "Collections",
        "Cookie",
        "HasMany",
        "HasOne",
        "MockServer",
        "Model",
        "Models",
        "Relationship",
        "ScopeCollection",
        "Url",
        "Validator",
        "WeatherByZip",
        "WeatherByZipAll",
        "WeatherByZipCount",
        "WeatherByZipCountExactMatch",
        "WeatherByZipExactMatch",
        "WeatherSoapAppSdk"
    ],
    "modules": [
        "AP",
        "MockServer",
        "WeatherSoapAppSdk",
        "auth",
        "collection",
        "collections",
        "model",
        "models",
        "relationship",
        "utility"
    ],
    "allModules": [
        {
            "displayName": "AP",
            "name": "AP",
            "description": "Provides the global namespace for SDK framework classes.  Provides convenience\nmethods for app management."
        },
        {
            "displayName": "auth",
            "name": "auth",
            "description": "Provides methods for user authentication and deauthentication.\n\nTo login (Coffeescript):"
        },
        {
            "displayName": "collection",
            "name": "collection",
            "description": "Unlike a normal `AP.collection.Collection`, aggregate collections expect a\nsimple integer-only response from the server.  Aggregate collections are always\nzero-length (they have no members).  They have an extra member `value`."
        },
        {
            "displayName": "collections",
            "name": "collections",
            "description": "WeatherByZipAllis a scope collection for application `WeatherSoapAppSdk`.  See\n`AP.collection.ScopeCollection` for more information about scopes."
        },
        {
            "displayName": "MockServer",
            "name": "MockServer",
            "description": "Mock server instances are used by the test framework to intercept XHR requests\nand simulate the functionality of an API backend, entirely offline.  A mock\nserver handles all requests matching collections within the application within\nwhich it is instantiated.\n\nTo enable a mock server in an application, simply enable the global\n`useMockServer` flag:"
        },
        {
            "displayName": "model",
            "name": "model",
            "description": "Base model class.  In addition to the standard methods provided by the\n[BackboneJS model class](http://backbonejs.org/#Model), this base model\nimplements full validations support.\n\nThis model should be subclassed, not used directly.  For example (Coffeescript):"
        },
        {
            "displayName": "models",
            "name": "models",
            "description": "WeatherByZip model for application `WeatherSoapAppSdk`.  See\n`AP.model.Model` for more information about models."
        },
        {
            "displayName": "relationship",
            "name": "relationship",
            "description": "A belongs-to relationship is one where the owner model instance is related to\nno more than one other model instance.  In this scheme, the relationship\ninformation is stored in a foreign key on the owner model.  The related instance\nis stored in a generated field {@link #name} once fetched.\n\nFor example, if the foreign key is `user_id` and the relationship name is `user`\nthen the related instance may be obtained by calling:"
        },
        {
            "displayName": "utility",
            "name": "utility",
            "description": "Utility singleton for encoding and decoding Base64 strings."
        },
        {
            "displayName": "WeatherSoapAppSdk",
            "name": "WeatherSoapAppSdk"
        }
    ]
} };
});