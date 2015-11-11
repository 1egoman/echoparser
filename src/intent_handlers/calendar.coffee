fs = require 'fs'
readline = require('readline')
google = require('googleapis')
googleAuth = require('google-auth-library')
Promise = require "promise"

SCOPES = ['https://www.googleapis.com/auth/calendar']
TOKEN_DIR = (
  process.env.HOME ||
  process.env.HOMEPATH ||
  process.env.USERPROFILE
) + '/.credentials/'
TOKEN_PATH = TOKEN_DIR + 'calendar-nodejs-echoparser.json'


# manage oauth
oauth = exports.oauth =

  init: (redirect_uri) ->
    @auth = new googleAuth
    @oauth2 = new @auth.OAuth2(
      "796368167408-9rmitp7n43umec1fmoapdhvolg7tb9mg.apps.googleusercontent.com",
      "_QzR0qI0FRfBwfV1DGGsjeAM",
      redirect_uri
    )

    # check for token and set if it exists
    if @token then @oauth2.credentials = @token

  getName: -> "Google Calendar"

  # where to redirect the user to for the first step of oauth
  redirectUserTo: ->
    @oauth2.generateAuthUrl
      access_type: 'offline',
      scope: SCOPES

  # given a request object, extract the token
  getToken: (req) ->
    new Promise (resolve, reject) =>
      token = req.query.code
      @oauth2.getToken token, (err, @token) =>
        if err
          reject err.toString()
        else
          @oauth2.credentials = @token
          resolve @token

# get calendar events for the next day
exports.listUpcomingEvents = (interaction, intent) ->
  calendar = google.calendar('v3')
  calendar.events.list {
    auth: oauth.oauth2

    calendarId: intent.data.calendar or 'primary'
    timeMin: new Date().toISOString()
    timeMax: new Date(new Date().getTime() + 86400).toISOString() # one day from the start
    maxResults: 10
    singleEvents: true
    orderBy: 'startTime'
  }, (err, response) ->
    if err
      interaction.form_response true, "Google Calendar returned an error: #{err}", true
    else
      response = response.items.map (event) ->
        start = event.start.dateTime or event.start.date
        "#{event.summary} at #{start}"

      if response.length
        interaction.form_response false, response.join(', '), true
      else
        interaction.form_response false, "No events for the next day are on your calendar.", true
