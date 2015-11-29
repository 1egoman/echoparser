Twitter = require('simple-twitter')
request = require("request")
{OAuth} = require('oauth')
_ = require("underscore")

TWITTER_APP_CONSUMER_KEY = "bdhW2HyVRjwTr8eF1z6xG2Fww"
TWITTER_APP_CONSUMER_SECRET = "Tw90iWhUlb41YtimB1dXL6jnihX5PtxZx8kAdypOc5DW6hfjG6"
 
oauth = exports.oauth =
  init: (redirect_uri) ->
    @auth = {} # reset stored auth
    @oauth = new OAuth(
      "https://api.twitter.com/oauth/request_token",
      "https://api.twitter.com/oauth/access_token",
      TWITTER_APP_CONSUMER_KEY,
      TWITTER_APP_CONSUMER_SECRET,
      "1.0",
      redirect_uri,
      "HMAC-SHA1"
    )

    # alias auth to token
    @auth = @token if @token

  getName: -> "Twitter"

  redirectUserTo: (done) ->
    @oauth.getOAuthRequestToken (error, oauth_token, oauth_token_secret, results) =>
      @auth = {
        oauth_token: oauth_token,
        oauth_token_secret: oauth_token_secret
      }
      done error, 'https://twitter.com/oauth/authenticate?oauth_token='+oauth_token

  # fetch the token from twitter
  getToken: (req) ->
    new Promise (resolve, reject) =>
      oauth_token = req.query.oauth_token
      oauth_verifier = req.query.oauth_verifier

      if oauth_token and oauth_verifier
        @oauth.getOAuthAccessToken(
          @auth.oauth_token,
          @auth.oauth_token_secret,
          oauth_verifier,
          (error, oauth_access_token, oauth_access_token_secret) =>
            if error
              reject error
            else
              @auth.access_token = oauth_access_token
              @auth.access_token_secret = oauth_access_token_secret
              resolve @auth
        )
      else
        reject "User never visited auth url!"

  makeTwitterClient: ->
    if @client
      @client
    else
      @client = new Twitter(
        TWITTER_APP_CONSUMER_KEY,
        TWITTER_APP_CONSUMER_SECRET,
        @token.access_token,
        @token.access_token_secret
      )

exports.sendTweet = (interaction, intent) ->
  params = {
    status: intent.data.body,
  }
  interaction.form_response false, "Tweet '#{params.status}'?"
  interaction.await_response {}, (err, intent_response) ->
    if intent_response.name is "responses.yes"

      # trim to 140 chars because twitter...
      params.status = params.status.toString().slice(0, 140)

      # capitalize the first letter of the tweet because grammer
      params.status = params.status[0].toUpperCase() + params.status.slice(1)

      # post the tweet
      oauth.makeTwitterClient().post 'statuses/update', params, (error, tweet_str, response) ->
        console.log(error, tweet)

        if error
          interaction.form_response error, "Twitter returned an error: #{JSON.stringify(error)}", true
        else

          # parse the return to json
          try
            tweet = JSON.parse(tweet_str)
          catch e
            return interaction.form_response e, "Twitter didn't return valid JSON?", true

          interaction.raw_response
            outputSpeach:
              type: "PlainText"
              text: "The tweet was posted."

            # pass content to the response so it can be opened somewhere else
            outputContent: [
              type: "WebLink",
              data: "https://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id_str}"
            ]

            shouldEndSession: true

    else
      interaction.end_response()

