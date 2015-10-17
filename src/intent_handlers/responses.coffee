exports.yes = exports.no = (interaction) ->
  interaction.form_response true, "That makes no sense!", true
