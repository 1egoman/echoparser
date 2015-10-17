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
      if response.name is "responses.yes"
        interaction.form_response true, "Playing #{tracks[0].name}...", true
      else
        interaction.end_response()

# serch for the phrase specified and find a matching track
exports.playMusicArtist = (interaction, intent) ->
  console.log 1

  # get artist details
  spotify.searchArtists(intent.data.artist, limit: 1).then (data) ->
    if data and artist = data.body?.artists?.items[0]

      # get the top tracks for an artist
      spotify.getArtistTopTracks(artist.id, 'US').then (data) ->
        tracks = data.body.tracks.map (t) ->
          name: t.name
          artist: t.artists.map((a) => a.name).join ', '
          src: t.preview_url
        interaction.audio_playlist_response true, tracks, \
          "I've assembled a playlist of #{artist.name}. Play it?"

      interaction.await_response {}, (err, response) ->
        console.log err, response
        if response.name is "responses.yes"
          interaction.raw_response
            outputSpeach:
              text: "Ok"
            actions: [name: "play.media"]
            shouldEndSession: true
        else
          interaction.end_response()



# play something
# exports.playMusicName new Interaction,
#   name: 'audio.playMusicName'
#   data:
#     name: "stuff you should know"
