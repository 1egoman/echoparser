Interaction = require "../interaction"

Spotify = require "spotify-web-api-node"
spotify = new Spotify

base64 = require "base-64"
require("request")
  method: 'POST'
  url: 'https://accounts.spotify.com/api/token'
  headers:
    'content-type': 'application/x-www-form-urlencoded'
    'cache-control': 'no-cache'
    authorization: "Basic #{base64.encode process.env.SPOTIFY_APP_CLIENTID+':'+process.env.SPOTIFY_APP_SECRET}"
  form: grant_type: 'client_credentials'
, (err, resp, body) ->
  if not err and body
    spotify.setAccessToken body.access_token
    console.log "-> Authorized Spotify."
  else
    console.log err
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

        # wait for the user confirmation
        interaction.await_response {}, (err, response) ->
          console.log err, response

          # play it
          if response.name is "responses.yes"
            interaction.raw_response
              outputSpeach:
                type: "PlainText"
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
