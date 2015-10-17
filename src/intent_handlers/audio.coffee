Interaction = require "../interaction"

Spotify = require "spotify-web-api-node"
spotify = new Spotify

async = require "async"

tunein = require "tunein_scraper"

base64 = require "base-64"
request = require("request")
request
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

# get play a random track
exports.playMusicGeneral = (interaction, intent) ->
  interaction.form_response true, "Not implemented.", true

# get a track to play from an adjective
exports.playMusicDescriptor = (interaction, intent) ->
  interaction.form_response true, "Not implemented.", true

# search for the phrase specified and find a matching track
exports.playMusicName = (interaction, intent) ->
  spotify.searchTracks(intent.data.name, limit: 1).then (data) ->
    if tracks = data.body.tracks.items

      interaction.form_response true, \
      "Play #{tracks[0].name} by #{tracks[0].artists[0].name}?"

      interaction.await_response {}, (err, response) ->
        if response.name is "responses.yes"
          interaction.audio_response true, do (t=tracks[0]) ->
            name: t.name
            artist: t.artists.map((a) => a.name).join ', '
            src: t.preview_url
          , "Playing #{tracks[0].name}...", true
        else
          interaction.end_response()
    else
      interaction.form_response true, "Couldn't find anything like that.", true


# search for the phrase specified and find a matching track
exports.playMusicNameArtist = (interaction, intent) ->
  spotify.searchTracks "track:#{intent.data.name} artist:#{intent.data.artist}",
    limit: 1
  .then (data) ->
    console.log data
    if tracks = data.body.tracks.items

      interaction.form_response true, \
      "Play #{tracks[0].name} by #{tracks[0].artists[0].name}?"

      interaction.await_response {}, (err, response) ->
        if response.name is "responses.yes"
          interaction.audio_response true, do (t=tracks[0]) ->
            name: t.name
            artist: t.artists.map((a) => a.name).join ', '
            src: t.preview_url
          , "Playing #{tracks[0].name}...", true
        else
          interaction.end_response()
    else
      interaction.form_response true, "Couldn't find anything like that.", true


# search for the phrase specified and find a matching track
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

    else
      interaction.form_response true, "Couldn't find anything like that.", true


exports.addToPlaylist = (interaction, intent) ->
  spotify.searchTracks(intent.data.name, limit: 1).then (data) =>
    if data.body.tracks.items.length > 0
      interaction.form_response true, "Not Implemented. Later, we'll add #{data.body.tracks.items[0].name} to playlist."
    else
      interaction.form_response true, data


exports.playPlaylist = (interaction, intent) ->
  spotify.searchPlaylists(intent.data.playlist).then (data) ->
    if playlist = data.body.playlists.items[0]
      interaction.form_response true, "Not Implemented. Later, we'll play #{playlist.name}.", true
    else
      interaction.form_response true, "No such playlist exists", true


# search for a podcast and play it
exports.playPodcastName = (interaction, intent) ->
  tunein.searchForShow(intent.data.name).then (data) ->
    if data.length > 0
      podcast = data[0]

      tunein.getEpisodesOfShow(podcast).then (episodes) ->
        if episodes.length > 0
          episode = episodes[0]

          # get the stream for each episode
          async.map episodes, (e, cb) ->
            tunein.getStreamData(e).then (stream_data) ->
              stream = stream_data.Streams.filter((a) -> a.Type is "Download")
              if stream
                e.src = stream[0].Url
              cb null, e
          , (err, tracks) =>
            interaction.audio_playlist_response true, tracks, "Play '#{episode.name}' from '#{podcast.name}'?"

            # wait for the user to confirm
            interaction.await_response {}, (err, response) ->

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

        else
          interaction.form_response true, "No episodes of #{podcast.name} found."
    else
      interaction.form_response true, "No podcasts was found."

# play something
# exports.playMusicName new Interaction,
#   name: 'audio.playMusicName'
#   data:
#     name: "stuff you should know"
