fs = require 'fs'
readline = require('readline')
google = require('googleapis')
googleAuth = require('google-auth-library')
Promise = require "promise"
moment = require "moment"

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
      process.env.GOOGLE_APP_CLIENTID,
      process.env.GOOGLE_APP_SECRET,
      redirect_uri
    )

    # check for token and set if it exists
    if @token then @oauth2.credentials = @token

  getName: -> "Google Calendar"

  # where to redirect the user to for the first step of oauth
  redirectUserTo: (done) ->
    done null, @oauth2.generateAuthUrl
      access_type: 'offline',
      scope: SCOPES

  # given a request object, extract the token
  # this is called after the user clicks "allow" on the oauth prompt
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
  if oauth.token
    calendar = google.calendar('v3')
    calendar.events.list {
      auth: oauth.oauth2

      calendarId: intent.data.calendar or 'primary'
      timeMin: new Date().toISOString()
      timeMax: moment().add(1, 'days').toISOString()
      maxResults: intent.data.quantity or 10
      singleEvents: true
      orderBy: 'startTime'
    }, (err, response) ->
      if err
        interaction.form_response true, "Google Calendar returned an error: #{err}", true
      else
        response = response.items.map (event) ->
          start = event.start.dateTime or event.start.date
          "'#{event.summary}' at #{moment(start).format("h:mm a")}"

        if response.length
          interaction.form_response false, "Today, you've got #{response.join(', ')}.", true
        else
          interaction.form_response false, "No events for the next day are on your calendar.", true
  else
    interaction.form_response false ,"Please give me permission to access Google Calendar!", true



# add a new event to the calendar
exports.addEvent = (interaction, intent) ->
  if oauth.token
    calendar = google.calendar('v3')

    # calculate when the event will end
    end = moment(intent.data.start).add(intent.data.duration or 10, "minutes").toDate()
    event = {
      'summary': intent.data.event
      'description': '(quick-add via echoparser)',
      'start': {
        'dateTime': intent.data.start.toISOString(),
        'timeZone': 'America/New_York',
      },
      'end': {
        'dateTime': end,
        'timeZone': 'America/New_York',
      },
      'attendees': [],
      'reminders': { 'useDefault': true }
    }

    calendar.events.insert {
      auth: oauth.oauth2

      calendarId: intent.data.calendar or 'primary'
      resource: event
    }, (err, response) ->
      if err
        console.log(err)
        interaction.form_response true, "Google Calendar returned an error: #{err}", true
      else
        interaction.raw_response
          outputSpeach:
            type: "PlainText"
            text: "Event '#{intent.data.event}' added."

          # pass content to the response so it can be opened somewhere else
          outputContent: [
            type: "WebLink",
            data: response.htmlLink
          ]

          shouldEndSession: true

  else
    interaction.form_response false ,"Please give me permission to access Google Calendar!", true
