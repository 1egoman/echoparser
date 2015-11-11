fs = require "fs"
path = require "path"
Promise = require "promise"
async = require "async"

# return all clients that require oauth to work
exports.get_oauth_clients = ->
  new Promise (resolve, reject) ->
    fs.readdir path.join("src", "intent_handlers"), (err, dir) ->
      if err
        reject err
      else
        dir = dir
        .filter (i) -> i[0] isnt '.' # remove all 'hidden' filed
        .map (i) -> i.split('.')[0] # remove file extension

        async.map dir, (i, cb) -> # make sure they have an oauth module defined
          try
            {oauth} = require "./intent_handlers/#{i}"
          catch
            # no module of that name exists
            return cb null, false

          if oauth
            exports.read_token(i).then (data) ->
              cb null,
                raw_name: i
                name: oauth.getName()
                module: oauth
                token: data.token

            .catch (err) ->
              cb null,
                raw_name: i
                name: oauth.getName()
                module: oauth
          else
            # no such oauth handler exists
            cb null, false
        , (err, all) ->
          if err
            reject err
          else
            resolve all.filter (i) -> # remove those with i.module == undefined
              i and i.module isnt undefined

# run 'init' for all of the functions
exports.init_oauth_clients = (base_url) ->
  exports.get_oauth_clients()
  .then (clients) ->
    for c in clients
      redirect_uri = "#{base_url}/oauth/callback/#{encodeURIComponent(c.raw_name)}"
      console.log "-> Setting up oauth for '#{c.name}' with redirect of #{redirect_uri}"

      # put tke token into the oauth manager
      c.module.token = c.token
      c.module.init redirect_uri

# a new token is received
exports.register_token = (req, res) ->
  try
    {oauth} = require "./intent_handlers/#{path.normalize req.params.name}"
  catch
    return res.status(400).send "No such intent '#{req.params.name}'"

  # return the token from the request
  oauth.getToken(req).then (token) ->
    console.log token

    # save it
    exports.save_token(req.params.name, token)
    .then(-> res.redirect "/oauth")
    .catch((err) -> res.send error: err)

  .catch (err) ->
    res.send error: err

# save a token to file
exports.save_token = (name, token) ->
  new Promise (resolve, reject) ->
    obj = {
      name: name,
      token: token
    }

    fs.writeFile path.join("./config", "oauth", "#{name}.json"), JSON.stringify(obj, null, 2), (err) ->
      if err
        reject(err)
      else
        resolve()

# read a token from disk
exports.read_token = (name) ->
  new Promise (resolve, reject) ->
    fs.readFile path.join("./config", "oauth", "#{name}.json"), (err, data) ->
      if err
        reject(err)
      else
        try
          data = JSON.parse(data)
        catch err
          return reject(err)

        resolve data


