fs = require 'fs'
readline = require('readline')
google = require('googleapis')
googleAuth = require('google-auth-library')

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

  getName: -> "Google Calendar"

  # where to redirect the user to for the first step of oauth
  redirectUserTo: ->
    @oauth2.generateAuthUrl
      access_type: 'offline',
      scope: SCOPES

  # given a request object, extract the token
  getToken: (req) ->
    token = req.query.code
    @oauth2.credentials = token
    token


###*
# Lists the next 10 events on the user's primary calendar.
#
# @param {google.auth.OAuth2} auth An authorized OAuth2 client.
###

exports.listEvents = (interaction, intent) ->
  calendar = google.calendar('v3')
  calendar.events.list {
    auth: oauth.oauth2
    calendarId: 'primary'
    timeMin: (new Date).toISOString()
    maxResults: 10
    singleEvents: true
    orderBy: 'startTime'
  }, (err, response) ->
    if err
      console.log 'The API returned an error: ' + err
      return
    events = response.items
    if events.length == 0
      console.log 'No upcoming events found.'
    else
      console.log 'Upcoming 10 events:'
      i = 0
      while i < events.length
        event = events[i]
        start = event.start.dateTime or event.start.date
        console.log '%s - %s', start, event.summary
        i++
    return
  return
