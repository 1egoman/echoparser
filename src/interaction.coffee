{EventEmitter} = require "events"
uuid = require "uuid"
chalk = require "chalk"

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

  constructor: ->
    @id = uuid.v4()
    @intents = []

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

    @DEBUG = true

  # tell us that we'd like to respond to what the user said
  # this is a helper to make the responses look good and easy for uesers to
  # remember.
  # status is a boolean: currently not used
  # text is what to say back
  # end_session is whether to terminate the session on completion of this
  # response.
  form_response: (status, text, end_session=false) ->
    @emit "intent_response",
      outputSpeech:
        type: "PlainText"
        text: text
      shouldEndSession: end_session

  # just end the interaction with no response back
  end_response: ->
    @emit "intent_response",
      outputSpeech: null
      shouldEndSession: true

  # wait for a new intent and feed it to whoever asks
  await_response: (opts={}, callback) ->
    @once "intent", (data) -> callback null, data

  format_intent: (intent) ->
    # add interaction id to the response
    intent.interactionId = @id
    intent

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


