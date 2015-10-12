Interaction = require "../interaction"

# end the interaction immediately
exports.stop = (interaction, intent) -> interaction.end_response()

# end the interaction immediately
exports.repeat = (interaction, intent) -> interaction.end_response()
