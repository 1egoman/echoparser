
exports.getWeatherForLocation = (interaction, intent) ->
  console.log intent.data.place
  interaction.form_response false, "weather: #{intent.data.place.raw}"

exports.getWeatherForCurrentLocation = (interaction, intent) ->
  interaction.form_response false, "weather: #{intent.data}"
