{EventEmitter} = require "events"
class Interaction extends EventEmitter

  constructor: -> @DEBUG = true

  # tell us that we'd like to respond to what the user said
  # this is a helper to make the responses look good and easy for uesers to
  # remember
  form_response: (status, text, end_session=false) ->
    @emit "intent_response",
      outputSpeech:
        type: "PlainText"
        text: text
      shouldEndSession: end_session

  await_response: (opts={}, callback) ->
    @once "intent", (data) -> callback null, data

  # debug logging
  emit: ->
    if @DEBUG
      console.log.apply console, ["->"].concat Array.prototype.slice.apply arguments
    super

  # on: ->
  #   if @DEBUG
  #     console.log.apply console, ["<-"].concat Array.prototype.slice.apply arguments
  #   super



# serch for the phrase specified and find a matching track
Spotify = require "spotify-web-api-node"
spotify = new Spotify
exports.playMusicName = (interaction, intent) ->
  spotify.searchTracks(intent.data.name, limit: 1).then (data) ->

    tracks = data.body.tracks.items

    interaction.form_response true, "Play #{tracks[0].name} by #{tracks[0].artists[0].name}?", false
    interaction.await_response {}, (err, response) ->
      if response.name is "utils.yes"
        interaction.form_response true, "Playing #{tracks[0].name}...", true


# play ring of fire
exports.playMusicName new Interaction,
  name: 'audio.playPodcastName'
  data:
    name: "stuff you should know"
