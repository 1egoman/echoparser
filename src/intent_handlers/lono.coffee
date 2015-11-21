fs = require 'fs'
Promise = require "promise"
request = require "request"

# manage oauth
oauth = exports.oauth =

  init: (@redirect_uri) ->
    @client_id = "a0a56a72-83c6-4f6b-8b0e-37924f466233"
    @client_secret = "0c360715-d76e-4f3e-bb48-abe49a20bf6b"

  getName: -> "Lono"

  # where to redirect the user to for the first step of oauth
  redirectUserTo: ->
    "http://make.lono.io/dialog/authorize?response_type=code&client_id=#{@client_id}&redirect_uri=#{@redirect_uri}&scope=write"

  # given a request object, extract the token
  # this is called after the user clicks "allow" on the oauth prompt
  getToken: (req) ->
    new Promise (resolve, reject) =>
      token = req.query.code
      resolve {
        auth_token: token
      }

  # a totally custom method
  # exchange an auth token for an access token
  getClientToken: ->
    new Promise (resolve, reject) =>
      request {
        method: 'POST',
        url: 'http://make.lono.io/oauth/token',
        json: {
          "grant_type": "authorization_code",
          "client_id": @client_id,
          "client_secret": @client_secret,
          "code": @token.auth_token
        }
      }, (err, resp, body) ->
        if err
          reject err
        else
          resolve body




# turn on or off a zone manually
exports.zoneState = (interaction, intent) ->
  if oauth.token and intent.data.n and intent.data.action in ["on", "off"]
    oauth.getClientToken().then (data) ->
      request {
        method: "POST",
        url: "http://make.lono.io/api/v1/devices/34ffda053257333933870457/zones/#{intent.data.n}/#{intent.data.action}?token=#{data.access_token}"
      }, (err, resp, body) ->
        if err
          interaction.form_response false, "Error with Lono: #{err}", true
        else
          console.log(body)
          interaction.form_response false, "Turned #{intent.data.action} zone #{intent.data.n}.", true
  else
    interaction.form_response false, "Please give me permission to access your Lono!", true
