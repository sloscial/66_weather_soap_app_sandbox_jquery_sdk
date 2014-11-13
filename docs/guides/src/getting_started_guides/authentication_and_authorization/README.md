The SDK ships with a complete auth system.  It handles all details of auth including login/logout, session management, and role-based authorization.


## Authentication

Authentication using the AnyPresenece HTML5 SDK is painless.  Login and logout calls are made in one line each.

    AP.auth.Authentication.login({username: 'test', password: 'password'})
    AP.auth.Authentication.logout()

There are three auth-related events developers may listen on.

    AP.auth.Authentication.on('auth:authenticated', loginHandlerFn)
    AP.auth.Authentication.on('auth:deauthenticated', logoutHandlerFn)
    AP.auth.Authentication.on('auth:error, loginFailedHandlerFn)


## Accessing User Data

Getting the username or role of the currently logged-in user is simple:
    
    username = AP.auth.Authentication.getUsername()
    role = AP.auth.Authentication.getUserRole()

Information about the currently logged-in user is available from the auth method `AP.auth.Authentication.getAuthSessionData`.  In many cases, however, accessing the user object directly is unnecessary.

    # returns an object of key/value data associated with the currently
    # authenticated user
    user = AP.auth.Authentication.getAuthSessionData()


## Authorization

Role-based authorization is simple.  After a successful login attempt, authorization checks may be performed on the currently authenticated user.  For example:

    AP.auth.Authorization.isAuthorized([{roles: 'manager'}, {roles: 'admin'}])
    # returns true if logged-in user has _either_ `manager` _or_ `admin` roles
    
    AP.auth.Authorization.isAuthorized([{roles: 'manager,admin'}])
    # returns true if logged-in user has both `manager` _and_ `admin` roles

That's it.  No need to look-up the user object and manually process user roles.
