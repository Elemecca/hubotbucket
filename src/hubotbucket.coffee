
OAuth = require 'oauth'
Async = require 'async'
URL   = require 'url'

version = require( '../package.json' )[ 'version' ]

class Bitbucket
  constructor: (@logger, @options) ->
    @oauth = new OAuth.OAuth \
      null, null, # token URLs
      @_opt( 'clientKey' ), @_opt( 'clientSecret' ),
      '1.0', null, 'HMAC-SHA1', null,
        'Accept':     'application/json'
        'User-Agent': 'HubotBucket/' + version
        'Connection': 'keep-alive'

    @queue = Async.queue (task, callback) =>
        task.run callback
      , @_opt 'concurrentRequests'

  qualifyRepo: (repo) ->
    unless repo?
      unless (repo = @_opt 'defaultRepo')?
        @logger.warning 'default Bitbucket repo not specified'
        return null

    repo = repo.toLowerCase()
    return repo unless repo.indexOf( '/' ) is -1

    unless (user = @_opt 'defaultUser')?
      @logger.warning 'default Bitbucket user not specified'
      return null

    "#{user}/#{repo}"

  request: (method, url, data, callback) ->
    [callback, data] = [data, null] unless callback?

    url = URL.format( url ) if typeof url is 'object'
    url = URL.resolve( @_opt( 'apiBase' ), url )

    # build the @oauth method call based on HTTP method
    method = method.toLowerCase()
    switch method
      when 'get', 'delete'
        task = run: (callback) =>
          @oauth[ method ] url, null, null, callback

      when 'post', 'put'
        task = run: (callback) =>
          @oauth[ method ] url, null, null,
            JSON.stringify( data ) if data? else '',
            'application/json', callback

      else throw new Error \
        "unsupported method #{method} in request for #{url}"

    @queue.push task, (error, data, message) =>
      if error?
        return @_errorHandler
          statusCode: message?.statusCode
          body:       data
          error:      error

      try
        data = JSON.parse data if data?
      catch caught
        return @_errorHandler
          statusCode: response?.statusCode
          body:       data
          error:      "couldn't parse response body: #{caught}"

      callback data

  get:    (args...) -> @request 'get',    args...
  put:    (args...) -> @request 'put',    args...
  post:   (args...) -> @request 'post',   args...
  delete: (args...) -> @request 'delete', args...

  _errorHandler: (response) ->
    if response.statusCode?
      try
        body = JSON.parse response.body
        message = body.error.message
      catch caught
        message = "unknown error"

      message = "#{response.statusCode} #{message}"

    else
      message = response.error

    @logger.error message

  _opt: (name) ->
    @options ?= {}
    @options[ name ] ? @_optFromEnv( name )

  _optFromEnv: (name) ->
    switch name
      when 'clientKey'
        process.env.HUBOT_BITBUCKET_KEY
      when 'clientSecret'
        process.env.HUBOT_BITBUCKET_SECRET
      when 'apiBase'
        process.env.HUBOT_BITBUCKET_API ?
          'https://bitbucket.org/api/'
      when 'defaultUser'
        process.env.HUBOT_BITBUCKET_USER
      when 'defaultRepo'
        process.env.HUBOT_BITBUCKET_REPO
      when 'concurrentRequests'
        process.env.HUBOT_CONCURRENT_REQUESTS ? 20
      else null

module.exports = (robot, options = {}) ->
  new Bitbucket robot.logger, options

