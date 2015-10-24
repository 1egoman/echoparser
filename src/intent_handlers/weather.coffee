
exports.getWeatherForLocation = (interaction, intent) ->
  interaction.form_response false, "weather: #{JSON.stringify intent.data}"

exports.getWeatherForCurrentLocation = (interaction, intent) ->
  interaction.form_response false, "weather: #{JSON.stringify intent.data}"
