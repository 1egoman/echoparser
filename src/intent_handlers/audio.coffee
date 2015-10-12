Interaction = require "../interaction"

Spotify = require "spotify-web-api-node"
spotify = new Spotify

# serch for the phrase specified and find a matching track
exports.playMusicName = (interaction, intent) ->
  spotify.searchTracks(intent.data.name, limit: 1).then (data) ->
    tracks = data.body.tracks.items

    interaction.form_response true, \
    "Play #{tracks[0].name} by #{tracks[0].artists[0].name}?", false

    interaction.await_response {}, (err, response) ->
      if response.name is "utils.yes"
        interaction.form_response true, "Playing #{tracks[0].name}...", true
      else
        interaction.end_response()


# play something
exports.playMusicName new Interaction,
  name: 'audio.playMusicName'
  data:
    name: "stuff you should know"
