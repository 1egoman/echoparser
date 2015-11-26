_ = require "underscore"

jokes = [
  "What is black, white, and red all over? A racoon in a blender!",
]

exports.getJoke = (interaction, intent) ->
  interaction.form_response false, _.sample(jokes), true
