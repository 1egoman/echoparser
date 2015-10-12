_ = require "underscore"
app = require("express")()
bodyParser = require "body-parser"
app.use bodyParser.json()

audio = require "./intent_handlers/audio"

# echo recognition functions
EchoLib = require "./echo_lib"

# library for managing interactions with user
Interaction = require "./interaction"

# access list of all skills
SkillsList = require "./echo_lib/skill_list"
skills_emitter = new SkillsList

app.get "/", (req, res) -> res.send "Hello World!"

# a list of all interactions happening
interaction_container = []

# get the code that is behind an intent
# look in intent_handles for the correctly named skill file
# and then get the intent from inside
get_intent_fn = (match_skill) ->
    skill_module = require "./intent_handlers/#{match_skill.name.split('.')[0]}"
    skill_module[match_skill.name.split('.')[1]]





# create a new interaction
app.post "/api/v1/intent", (req, res) ->

  # pull in latest skills
  skills_emitter.pull()
  skills_emitter.once "pull", (skills) ->

    # find the intent
    match_skill = EchoLib.get_matching_skills req.body.phrase, skills

    # create the interaction
    interaction = new Interaction
    interaction_container.push interaction
    interaction.emit "intent", match_skill

    # do the action
    # look in intent_handles for the correctly named skill file
    # and then get the intent from inside
    intent_module = get_intent_fn match_skill

    # wait for a response and go with it
    interaction.once "intent_response", (resp) ->
      res.send interaction.format_intent resp

    # run the intent
    if intent_module
      intent_module interaction, match_skill
    else
      interaction.form_response false, "The intent #{match_skill.name} has no handler."




# add onto an existing interaction
app.post "/api/v1/intent/:id", (req, res) ->

  # pull in latest skills
  skills_emitter.pull()
  skills_emitter.once "pull", (skills) ->

    # get the interaction that is referenced by the specified id
    interaction = do (id=req.params.id) ->
      all = interaction_container.filter (i) ->
        i.id is id
      all.length and all[0] or null

    # a good interaction id?
    if interaction is null
      return res.send error: "bad.interaction.id"

    # find the intent
    match_skill = EchoLib.get_matching_skills req.body.phrase, skills

    # wait for a response and go with it
    interaction.once "intent_response", (resp) ->
      # is the interaction complete?
      # clear it from the buffer then.
      if resp.shouldEndSession
        interaction_container = _.without interaction_container, interaction
      # send it out
      res.send interaction.format_intent resp

    # how should we handle the event?
    # if it's a global event, then call that skill and don't continue with the
    # current one.
    if match_skill.flags?.global?
      console.log "running global #{match_skill.name}..."
      intent_module = get_intent_fn match_skill
      intent_module interaction, match_skill
    else
      # send the intent to the interaction
      interaction.emit "intent", match_skill


PORT = process.env.PORT or 7000
app.listen PORT, ->
  console.log "-> #{PORT}"
