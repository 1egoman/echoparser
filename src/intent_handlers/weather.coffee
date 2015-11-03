Promise = require "promise"
Forecast = require "forecast.io"
_ = require "underscore"

# remove all returns in a string 
strip_n = (a) -> a.replace /[\n]/g, ''

# get the conditions at a specific location over time
get_conditions_at = (coords) ->
  new Promise (resolve, reject) ->
    if process.env.FORECASTIO_APP_API_KEY
      forecast = new Forecast
        APIKey: process.env.FORECASTIO_APP_API_KEY
        timeout: 1000

      forecast.get coords.lat, coords.lng, (err, res, data) ->
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
    get_conditions_at intent.data.place.geo
    .then (weather) ->

      # override the time if it is falsey
      time or= intent.data.time

      # get the closest condition to the point of reference
      conditions = resolve_forecast weather, time, resolution

      # format the forecast
      interaction.form_response false, strip_n(response(conditions, intent)), true

    # error?
    .catch (error) ->
      interaction.form_response false, error


# "It is 50 degrees and partly cloudy in New York."
exports.getWeatherForLocationNow = get_weather_at new Date, "hourly", (conditions, intent) ->
    """It is currently #{conditions.temperature} degrees 
    and #{conditions.summary} in #{intent.data.place.formatted}."""

exports.getRainForLocationNow = get_weather_at new Date, "hourly", (conditions, intent) ->
  """There is currently a 
  #{conditions.precipProbability * 100} percent chance of precipitation 
  in #{intent.data.place.formatted}."""

exports.getWeatherForCurrentLocationNow = (interaction, intent) ->
  interaction.form_response false, "Work in progress."
