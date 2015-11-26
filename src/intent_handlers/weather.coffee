Promise = require "promise"
Forecast = require "forecast.io"
_ = require "underscore"
moment = require "moment"

# remove all returns in a string 
strip_n = (a) -> a.replace /[\n]/g, ''

# get the conditions at a specific location over time
get_conditions_at = (coords) ->
  new Promise (resolve, reject) ->
    if process.env.FORECASTIO_APP_API_KEY
      forecast = new Forecast
        APIKey: process.env.FORECASTIO_APP_API_KEY
        timeout: 1000

      forecast.get coords.geo.lat, coords.geo.lng, (err, res, data) ->
        if err
          reject err
        else
          resolve data
    else
      reject "No forecast.io key. Please add one in FORECASTIO_APP_API_KEY and then try this again."

# for a given resolution and time in a given weather forecast, return the
# closest record.
resolve_forecast = (weather, time, resolution) ->
  conditions = weather[resolution]
  if conditions.data
    deltas = conditions.data.map (point) -> time - new Date(point.time * 1000)
    contitions_timestamp = _.min deltas
    conditions = conditions.data[deltas.indexOf(contitions_timestamp)]

  conditions

# this function abstracts all of the weather logic into a seperate container
get_weather_at = (time, resolution, response) ->
  (interaction, intent) ->

    # get the user's position
    # try to pull from the query, but fall back on request metadata
    if intent.data.place
      pos_of_user = intent.data.place
    else if interaction.metadata.geo
      pos_of_user = interaction.metadata.geo
    else
      return interaction.form_response true, "You never said where you were?", true

    get_conditions_at pos_of_user
    .then (weather) ->

      # override the time if it is falsey
      time or= intent.data.time

      # get the closest condition to the point of reference
      conditions = resolve_forecast weather, time, resolution

      # format the forecast
      interaction.form_response false, strip_n(response(conditions, intent, pos_of_user)), true

    # error?
    .catch (error) ->
      interaction.form_response false, error

# convert a degrees value into a textual version
degrees_to_text = (degrees) ->
  degrees %= 360

  switch
    when 0 <= degrees < 22.5 then return "North"
    when 22.5 <= degrees < 45 then return "North-Northwest"
    when 45 <= degrees < 67.5 then return "Northwest"
    when 67.5 <= degrees < 90 then return "West-Northwest"

    when 90 <= degrees < 112.5 then return "West"
    when 112.5 <= degrees < 135 then return "West-Southwest"
    when 15 <= degrees < 157.5 then return "Southwest"
    when 157.5 <= degrees < 180 then return "South-Southwest"

    when 180 <= degrees < 202.5 then return "South"
    when 202.5 <= degrees < 225 then return "South-Southeast"
    when 225 <= degrees < 247.5 then return "Southeast"
    when 247.5 <= degrees < 270 then return "East-Southeast"

    when 270 <= degrees < 292.5 then return "East"
    when 292.5 <= degrees < 315 then return "East-Northeast"
    when 315 <= degrees < 337.5 then return "Northeast"
    when 337.5 <= degrees < 360 then return "North-Northeast"
    else null

# "It is 50 degrees and partly cloudy in New York."
exports.getWeatherForLocationNow = get_weather_at new Date, "hourly", (conditions, intent, place) ->
  """It is currently #{conditions.temperature} degrees 
  and #{conditions.summary}#{place.formatted and " in "+place.formatted or ''}."""

# ------------------------------------------------------------------------------
#   Rain, Humidity, Dewpoint, Windspeed/direction, and visiblity
# ------------------------------------------------------------------------------

exports.getRainForLocationNow = get_weather_at new Date, "hourly", (conditions, intent, place) ->
  """There is currently a 
  #{Math.floor conditions.precipProbability * 100} percent chance of #{conditions.precipType or "precipitation"}
  #{place.formatted and " in "+place.formatted or ''}."""

exports.getHumidityForLocationNow = get_weather_at new Date, "hourly", (conditions, intent, place) ->
  """There is currently a #{Math.floor conditions.humidity * 100} percent humidity
  #{place.formatted and " in "+place.formatted or ''}."""

exports.getDewpointForLocationNow = get_weather_at new Date, "hourly", (conditions, intent, place) ->
  """The dewpoint is currently #{conditions.dewPoint} degrees
  #{place.formatted and " in "+place.formatted or ''}."""

exports.getWindspeedForLocationNow = get_weather_at new Date, "hourly", (conditions, intent, place) ->
  bearing = degrees_to_text(conditions.windBearing)
  """The wind is currently blowing at #{conditions.windSpeed} miles per hour#{bearing and ' to the '+bearing or ''}
  #{place.formatted and " in "+place.formatted or ''}."""

exports.getVisiblityForLocationNow = get_weather_at new Date, "hourly", (conditions, intent, place) ->
  """The visibility outside is #{conditions.visibility >= 10 and "not a limiting factor" or conditions.visibility+" miles"}
  #{place.formatted and " in "+place.formatted or ''}."""


# ------------------------------------------------------------------------------
#   Sun rising and setting time
# ------------------------------------------------------------------------------

exports.getSunriseTime = get_weather_at new Date, "daily", (conditions, intent, place) ->
  # check to see if when the sun rose, so we can compare and use the correct tense
  happened_before = new Date().getTime() / 1000 < conditions.sunriseTime
  """The sun #{happened_before and "rose" or "has risen"} at #{moment(conditions.sunriseTime * 1000).format("h:mm a")}
  #{place.formatted and " in "+place.formatted or ''}."""

exports.getSunsetTime = get_weather_at new Date, "daily", (conditions, intent, place) ->
  # check to see if when the sun rose, so we can compare and use the correct tense
  happened_before = new Date().getTime() / 1000 > conditions.sunsetTime
  """The sun #{happened_before and "set" or "will set"} at #{moment(conditions.sunsetTime * 1000).format("h:mm a")}
  #{place.formatted and " in "+place.formatted or ''}."""
