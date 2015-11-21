_ = require "underscore"
exports.yes = exports.no = (interaction) ->
  interaction.form_response true, _.sample([
    "That makes no sense!",
    "Umm, this isn't the place to say that.",
    "Excuse me?",
  ]), true
