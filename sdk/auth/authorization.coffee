AP.auth ?= {}


###*
Authorizes arbitrary objects against the currently logged-in user (see
`AP.auth.Authentication`).  Any object may be made permission-based by adding
an auth rules field.  If the currently logged-in user has _any role_ specified
in the rules array, it is considered authorized.

Example arbitrary permission-based object (Coffeescript):
@example
    myObject1 =
      member1: 'foo'
      rules: [{roles: 'manager'}, {roles: 'admin'}]
    # authorized if logged-in user has _either_ `manager` _or_ `admin` roles
    
    myObject2 =
      member: 'bar'
      rules: [{roles: 'manager,admin'}]
    # authorized if logged-in user has both `manager` and `admin` roles

Example usage (Coffeescript):
@example
    AP.auth.Authorization.isAuthorized(myObject1.rules)
    AP.auth.Authorization.isAuthorized(myObject2.rules)

@module AP
@submodule auth
@class Authorization
@static
###
class AP.auth.Authorization
  ###*
  @method isAuthorized
  @static
  @param {String} rules array of rule objects
  @return {Boolean} `true` if logged-in user has any role in at least one
  rule _or_ there are no rules
  ###
  @isAuthorized: (rules) ->
    return true if !rules? or rules.length == 0
    @_passesAnyRule(rules)
  
  ###*
  @private
  @method _passesAnyRule
  @static
  @param {String} rules array of rule objects
  @return {Boolean} `true` if logged-in user has any role in at least
  one rule
  ###
  @_passesAnyRule: (rules) ->
    for rule in rules
      return true if @_passesRule(rule)
    false
  
  ###*
  @private
  @method _passesRule
  @static
  @param {String} rule rule object
  @return {Boolean} `true` if logged-in user has any roles in rule object or
  rule has no roles specified
  ###
  @_passesRule: (rule) ->
    @_ruleHasNoRoles(rule) or @_hasAnyRole(rule.roles)
  
  ###*
  @private
  @static
  @method _ruleHasNoRoles
  @param {String} rule rule object
  @return {Boolean} `true` if rule has no `roles` field
  ###
  @_ruleHasNoRoles: (rule) -> !rule.hasOwnProperty('roles')
  
  ###*
  @private
  @static
  @method _hasAnyRole
  @param {String} roles_string string containing comma-separated role names
  @return {Boolean} `true` if logged-in user has any role in the roles string
  ###
  @_hasAnyRole: (roles_string) ->
    user_roles = @_getRoles()
    for role in roles_string.split(',')
      return true if user_roles.indexOf($.trim(role)) >= 0
    # if roles string is empty, than user is considered to have a matching role
    # simple by being logged in
    if !roles_string and AP.auth.Authentication.isAuthenticated()
      return true
    false
  
  ###*
  @private
  @static
  @method _getRoles
  @return {String[]} array of roles for the currently logged-in user.  Returns
  an empty array if no user is logged in.
  ###
  @_getRoles: ->
    authSettings = AP.auth.Authentication.getAuthenticationSettings()
    rolesField = authSettings.role_field
    data = AP.auth.Authentication.getUserRole()
    roles = if data? then data.split(',') else []
    roles.map (x) -> $.trim(x)
    roles
