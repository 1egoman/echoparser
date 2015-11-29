_ = require "underscore"

jokes = [
  "What is black, white, and red all over? A racoon in a blender!",
  "A horse walked into a bar. Multiple people left siteing the apparent danger.",
  "Past, present, and future walked into a bar. It was tense.",
  "A man walked into a bar. He said 'oww'!"
]

exports.getJoke = (interaction, intent) ->
  interaction.form_response false, _.sample(jokes), true

exports.helloWorld = (interaction, intent) ->
  interaction.form_response false, "Yea, that's what main() { printf(\"Hello, world!\"); } does.", true

exports.bestLanguage = (interaction, intent) ->
  interaction.form_response false, "Well, I'm a fan of javascript, but to each their own I guess...", true
