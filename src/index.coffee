_ = require "underscore"
path = require "path"
express = require("express")
app = express()
bodyParser = require "body-parser"
app.use bodyParser.json()
PORT = process.env.PORT or 7000

audio = require "./intent_handlers/audio"
app.use express.static path.join __dirname, '../public'

{new_interaction, continue_interaction} = require "./interaction_handler"

WebSocketServer = (require "ws").Server

oauth_helper = require "./oauth_helper"
oauth_helper.init_oauth_clients("http://localhost:#{PORT}") # the base oauth callback uri

# create a new interaction
app.post "/api/v1/intent", new_interaction

# add onto an existing interaction
app.post "/api/v1/intent/:id", continue_interaction

# oauth status page
app.get "/oauth", (req, res) ->
  oauth_helper.get_oauth_clients()
  .then (intents) ->
    intent_markup = intents.map (i) ->
      if i.token
        """
        <li>
          <strong>#{i.name}</strong>
          <span>#{JSON.stringify(i.token, null, 2)}</span>
        </li>
        """
      else
        """
        <li>
          <strong>#{i.name}</strong>
          <a href="#{i.module.redirectUserTo()}">Register</a>
        </li>
        """


    res.send """
    <h1>OAuth Permissions</h1>
    <ul>
      #{intent_markup.join('')}
    </ul>
    """

app.get "/oauth/callback/:name", oauth_helper.register_token


# websocket interface
WSPORT = process.env.WSPORT or 7070
wss = new WebSocketServer port: WSPORT
wss.on "connection", (ws) ->
  ws.on "message", (payload) ->
    
    # decode the request body
    try
      body = JSON.parse payload
    catch e
      ws.send error: "Invalid json."

    if not body.id
      # create a new interaction
      interaction = new_interaction
        body: body
        isWs: on
      ,
        send: (data) -> ws.send JSON.stringify(data)
    else
      continue_interaction
        body: body
        params:
          id: body.id
      ,
        send: (data) -> ws.send JSON.stringify(data)

app.listen PORT, ->
  console.log "-> #{PORT}"
