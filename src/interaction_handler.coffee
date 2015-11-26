_ = require "underscore"
EchoLib = require "./echo_lib"

# library for managing interactions with user
Interaction = require "./interaction"

# echo recognition functions
# access list of all skills
SkillsList = require "./echo_lib/skill_list"
skills_emitter = new SkillsList

# how much time makes an intent expired?
EXPIRED_INTENT_TIME = 60 * 1000 # 60 seconds

# a list of all interactions happening
exports.interaction_container = []


# get the code that is behind an intent
# look in intent_handles for the correctly named skill file
# and then get the intent from inside
get_intent_fn = (match_skill) ->
  if match_skill
    try
      skill_module = require "./intent_handlers/#{match_skill.name.split('.')[0]}"
    catch e
      console.log(e)
      return false
    skill_module[match_skill.name.split('.')[1]]
  else
    null


# filter new interactions and pull out the expired ones
# if a user leaves us hanging, then just stop the request
filter_expired = (interactions) ->
  current_time = new Date().getTime()
  interactions.filter((i) ->
    # get the datestamp that is the furthest back in time
    old_intent = _.max(i.intents, (j) -> j.datestamp)

    # the interaction hasn't progressed passed the threshhold for old intents
    is_old = old_intent.datestamp.getTime() + EXPIRED_INTENT_TIME < current_time
    i.end_response() if is_old

    not is_old
     
  )



# create a new interaction
exports.new_interaction = (req, res) ->
  # filter out old interactions
  exports.interaction_container = filter_expired exports.interaction_container

  # pull in latest skills
  skills_emitter.pull()
  skills_emitter.once "pull", (skills) ->

    # find the intent
    EchoLib.get_matching_skills req.body.phrase, skills, (match_skill) ->

      # create the interaction
      interaction = new Interaction
        ws: req.webSocketConn
        debug: true
        metadata: req.body.metadata # include any metadata sent in the request
      exports.interaction_container.push interaction
      interaction.emit "intent", match_skill

      # do the action
      # look in intent_handles for the correctly named skill file
      # and then get the intent from inside
      intent_module = get_intent_fn match_skill

      # wait for a response and go with it
      if req.isWs
        interaction.on "intent_response", (resp) ->
          res.send interaction.format_intent resp
      else
        interaction.once "intent_response", (resp) ->
          res.send interaction.format_intent resp

      # uhh, the code isn't on the filesystem
      if intent_module is false
        interaction.form_response true, "No such module in `intent_handlers`!!!", true

      # run the intent
      else if intent_module
        intent_module interaction, match_skill
      else
        # when in doubt, search wolfram
        interaction.search_wolfram req.body.phrase, null, true
        interaction.form_response false, "Sending request to wolfram alpha...", false
        # interaction.form_response false, \
        # "The intent #{match_skill and match_skill.name} has no handler.", false




# add onto an existing interaction
exports.continue_interaction = (req, res) ->

  # filter out old interactions
  exports.interaction_container = filter_expired exports.interaction_container

  # pull in latest skills
  skills_emitter.pull()
  skills_emitter.once "pull", (skills) ->

    # get the interaction that is referenced by the specified id
    interaction = do (id=req.params.id) ->
      all = exports.interaction_container.filter (i) ->
        i.id is id
      all.length and all[0] or null

    # a good interaction id?
    if interaction is null
      return res.send error: "bad.interaction.id"

    # find the intent
    EchoLib.get_matching_skills req.body.phrase, skills, (match_skill) ->

      # wait for a response and go with it
      interaction.once "intent_response", (resp) ->
        # is the interaction complete?
        # clear it from the buffer then.
        if resp.shouldEndSession
          exports.interaction_container = _.without exports.interaction_container, interaction
        # send it out
        res.send interaction.format_intent resp if not req.isWs

      # how should we handle the event?
      # if it's a global event, then call that skill and don't continue with the
      # current one.
      if match_skill and match_skill.flags?.global?
        console.log "running global #{match_skill.name}..."
        intent_module = get_intent_fn match_skill
        intent_module interaction, match_skill
      else
        if match_skill
          # send the intent to the interaction
          interaction.emit "intent", match_skill
        else
          # or, if there's no intent, send the raw data
          interaction.emit "intent",
            name: "raw"
            raw: req.body.phrase
            data: {}


