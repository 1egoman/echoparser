_ = require "underscore"

# echo recognition functions
EchoLib = require "./echo_lib"

# access list of all skills
SkillsList = require "./echo_lib/skill_list"
skills_emitter = new SkillsList

# tell us that we'd like to respond to what the user said
# this is a helper to make the responses look good and easy for uesers to
# remember
form_response = (status, text, end_session=false) ->
  outputSpeech:
    type: "PlainText"
    text: text
  shouldEndSession: end_session

# run an example query
skills_emitter.on "pull", (skills) ->
  match_skill = EchoLib.get_matching_skills "play the beatles", skills
  console.log "SKILL", match_skill

  # switch match_skill.name
  #
  #   # give a list of the numbers starting at n and going down by one
  #   when "repeat.repeatNumber"
  #     phrase = [0..match_skill.data.n].join ', '
  #     console.log form_response true, phrase, true
  #
  #
