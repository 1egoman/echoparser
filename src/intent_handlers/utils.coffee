Interaction = require "../interaction"

# end the interaction immediately
exports.stop = (interaction, intent) -> interaction.end_response()

# repeat the previous intent
exports.repeat = (interaction, intent) ->
  interaction.raw_response interaction.intents.reverse()[0].intent

# pause any media playing
exports.pause = (interaction, intent) ->
  interaction.raw_response
    actions: ["media.pause"],
    shouldEndSession: false

# control volume level
exports.setVolumeRelative = (interaction, intent) ->
  interaction.raw_response
    outputSpeach: null
    shouldEndSession: true
    hardwareOptions:
      volume:
        relative: intent.data.volume

exports.setVolumeAbsolute = (interaction, intent) ->
  interaction.raw_response
    outputSpeach: null
    shouldEndSession: true
    hardwareOptions:
      volume:
        absolute: intent.data.volume
