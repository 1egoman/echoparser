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


# "It is 50 degrees and partly cloudy in New York."
exports.getWeatherForLocationNow = get_weather_at new Date, "hourly", (conditions, intent, place) ->
    """It is currently #{conditions.temperature} degrees 
    and #{conditions.summary}#{place.formatted and " in "+place.formatted or ''}."""

exports.getRainForLocationNow = get_weather_at new Date, "hourly", (conditions, intent, place) ->
  """There is currently a 
  #{Math.floor conditions.precipProbability * 100} percent chance of precipitation
  #{place.formatted and " in "+place.formatted or ''}."""
