_ = require "underscore"
path = require "path"
express = require("express")
app = express()
bodyParser = require "body-parser"
app.use bodyParser.json()

audio = require "./intent_handlers/audio"
app.use express.static path.join __dirname, '../public'

{new_interaction, continue_interaction} = require "./interaction_handler"

WebSocketServer = (require "ws").Server

# create a new interaction
app.post "/api/v1/intent", new_interaction

# add onto an existing interaction
app.post "/api/v1/intent/:id", continue_interaction

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

PORT = process.env.PORT or 7000
app.listen PORT, ->
  console.log "-> #{PORT}"
