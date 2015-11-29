_ = require "underscore"

exports.hello = (interaction, intent) ->
  interaction.form_response false, _.sample([
    "Hello!",
    "What's shaking?",
    "Hi!",
    "Hello to you too!",
    "Always a pleasure!"
  ]), true
