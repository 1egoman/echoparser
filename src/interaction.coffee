{EventEmitter} = require "events"
uuid = require "uuid"
chalk = require "chalk"
_ = require "underscore"
wolfram = require("wolfram").createClient process.env.WOLFRAM_APP_KEY

# ------------------------------------------------------------------------------
# An interaction is the basic building block of communication.
# It is imporant to note that an interacion is like a conversation - after a
# while, one may no longer be active and be replaced with a new one.
#
# Send in an intent object:
# interaction_instance.emit("intent", {intent: "object here"})
#
# Listen for a response:
# interaction_instance.on("intent_response", function(intent) {
#   console.log(intent)
# })
# ------------------------------------------------------------------------------
module.exports = class Interaction extends EventEmitter

  constructor: (opts={debug: true})->
    @id = uuid.v4()
    @intents = []

    # TODO pull this in from a device
    @remote =
      playlist: []
      state: {}

    @on "intent_response", (intent) ->
      @intents.push
        direction: "outgoing"
        datestamp: new Date()
        intent: intent

    @on "intent", (intent) ->
      @intents.push
        direction: "incoming"
        datestamp: new Date()
        intent: intent

    @DEBUG = opts.debug

  # ----------------------------------------------------------------------------
  # Methods to respond to an intent with
  # ----------------------------------------------------------------------------

  # tell us that we'd like to respond to what the user said
  # this is a helper to make the responses look good and easy for uesers to
  # remember.
  # status is a boolean: currently not used
  # text is what to say back
  # end_session is whether to terminate the session on completion of this
  # response.
  form_response: (status, text, end_session=false) ->
    @emit "intent_response",
      outputSpeach:
        type: "PlainText"
        text: text
      shouldEndSession: end_session

  # just end the interaction with no response back
  end_response: ->
    @emit "intent_response",
      outputSpeach: null
      shouldEndSession: true

  # a raw response
  raw_response: (data) ->
    # were we passed something that wasn't an object?
    if not _.isObject data
      false
    else

      # audio changes we should be logging?
      # we want to know what the playlist of tracks looks like device-side
      if data.outputAudio
        if data.outputAudio.type.indexOf("playlist") isnt -1
          @remote.playlist = data.outputAudio
        else
          @remote.playlist = [data.outputAudio]

      # also, log any new actions that have changed states
      if data.actions
        for k,v of data.actions
          if _.isObject v
            @remote.state[k] = v
          else if _.isObject v
            delete @remote.state[k]
          else false

      # finally, emit the event
      @emit "intent_response", data

  # wait for a new intent and feed it to whoever asks
  await_response: (opts={}, callback) ->
    @once "intent", (data) -> callback null, data

  # format an intent to be sent out as a json object
  format_intent: (intent) ->
    # add interaction id to the response
    intent.interactionId = @id
    intent

  # ----------------------------------------------------------------------------
  # pass the query on to wolfram alpha
  # ----------------------------------------------------------------------------
  search_wolfram: (phrase, callback, end_session=false) ->
    # wolfram parsing function
    parse_wolfram_results = (results) ->
      pod = _.find results, (i) -> i.primary is true
      if pod
        pod.subpods[0].value

    wolfram.query phrase, (err, result) =>
      if callback
        # just send the data back to the user
        callback err, parse_wolfram_results(result), result
      else if not err
        @form_response true, parse_wolfram_results(result), end_session
      else
        @form_response true, "Wolfram Alpha errored: #{err}", end_session


  # ----------------------------------------------------------------------------
  # Stream an audio link to a device
  # This is played in the background and can be controlled with standard audio
  # actions.
  # ----------------------------------------------------------------------------
  audio_response: (status, audio_data, text=null, end_session=false) ->
    audio_data.type = "AudioLink"
    @raw_response
      outputSpeach: (if text
        type: "PlainText"
        text: text
      else undefined)
      outputAudio: audio_data
      shouldEndSession: end_session

  # ----------------------------------------------------------------------------
  # Stream a list of media to a device
  # This is played in the background and can be controlled with standard audio
  # actions. A playlist is an array of objects where each object has the key
  # "name", "artist", and "src" at minimum.
  # ----------------------------------------------------------------------------
  audio_playlist_response: (status, audio_playlist, text=null, end_session=false) ->
    @raw_response
      outputSpeach: (if text
        type: "PlainText"
        text: text
      else undefined)
      outputAudio:
        type: "AudioLinkPlaylist"
        playlist: do (audio_playlist) =>
          results = []
          audio_playlist.forEach (p) =>
            if p.name and p.src
              results.push p
          results
      shouldEndSession: end_session


  # debug logging
  emit: ->
    if @DEBUG
      console.log.apply console, [
        chalk.cyan @id,
        chalk.reset "->"
      ].concat Array.prototype.slice.apply arguments
    super

  # on: ->
  #   if @DEBUG
  #     console.log.apply console, ["<-"].concat Array.prototype.slice.apply arguments
  #   super


