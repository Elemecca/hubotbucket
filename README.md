# A Bitbucket API wrapper for Hubot

[![Build Status](https://travis-ci.org/Elemecca/hubotbucket.svg)](https://travis-ci.org/Elemecca/hubotbucket)
[![Dependency Status](https://gemnasium.com/Elemecca/hubotbucket.png)](https://gemnasium.com/Elemecca/hubotbucket)
[![NPM version](https://badge.fury.io/js/hubotbucket.png)](http://badge.fury.io/js/hubotbucket)

## Install ##

    npm install hubotbucket

## Require ##

Use it in your Hubot script:

```coffeescript
module.exports = (robot) ->
  bitbucket = require('hubotbucket')(robot)
```

You can pass additional [options](#options) to the constructor if needed.

## Use ##

Make any call to the [Bitbucket API][api] and get the parsed JSON response:

```coffeescript
bitbucket.get "1.0/repositories/you/your-repo/events", (events) ->
  console.log events.events[0].event

bitbucket.delete "1.0/users/you/ssh-keys/171052", (keys) ->
  console.log "deleted key " + keys[0].label

data = { "scm": "hg", "is_private": false, "description": "test repo" }
bitbucket.post "2.0/repostories/you/test", data, (repo) ->
  console.log repo.links.html.href

bitbucket.get "2.0/repositories/you/your-repo/pullrequests/20", (pr) ->
  pr.description = "a new description for an existsing PR"
  bitbucket.put pr.links.self.href, pr, (res) ->
    console.log "updated " + res.links.html.href
```

[api]: https://confluence.atlassian.com/display/BITBUCKET/Use+the+Bitbucket+REST+APIs

## Authentication ##

You can make requests that don't need authentication without taking
any special action. If you need to authenticate, you'll have to provide
an OAuth consumer token in `process.env.HUBOT_BITBUCKET_KEY` and
`process.env.HUBOT_BITBUCKET_SECRET`. If you don't yet have a token,
you can create one from the "Integrated applications" tab of your user
or team settings page. Just click the "Add consumer" button and fill
the fields out however you like.

## Helpful Hubot ##

If `process.env.HUBOT_BITBUCKET_USER` is present, we can help you
guess a repo's full name:

```coffeescript
bitbucket.qualifyRepo "hubotbucket" # => "elemecca/hubotbucket"
```

Similarly, if `process.env.HUBOT_BITBUCKET_REPO` is present its value
will be used when no repo is given at all:

```coffeescript
bitbucket.qualifyRepo() # => "elemecca/hubotbucket"
```

## Options ##

### Passing options ###

Options may be passed to hubotbucket in two different ways,
in increasing order of precedence:

1. Through shell environment variables.
2. Through the constructor:

   ```coffeescript
   bitbucket = require('hubotbucket')(robot, 'defaultUser': 'you') 
   ```

### Available options ###

* `clientKey` / `process.env.HUBOT_BITBUCKET_KEY`:
  Public half of the OAuth consumer token.
  Required to perform authenticated actions.

* `clientSecret` / `process.env.HUBOT_BITBUCKET_SECRET`:
  Private half of the OAuth consumer token.
  Required to perform authenticated actions.

* `defaultUser` / `process.env.HUBOT_BITBUCKET_USER`:
  Default username to use where one is not provided.

* `defaultRepo` / `process.env.HUBOT_BITBUCKET_REPO`:
  Default repository to use where one is not provided.
  Must include the username.

* `apiRoot` / `process.env.HUBOT_BITBUCKET_API`:
  The base API URL. Probably not useful.

* `concurrentRequests` / `process.env.HUBOT_CONCURRENT_REQUESTS`:
  Limits the allowed number of concurrent requests to the
  Bitbucket API. Defaults to 20.

## Contributing ##

Install the dependencies:

    npm install

**Pull requests encouraged!**

