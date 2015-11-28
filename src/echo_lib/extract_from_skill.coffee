_ = require "underscore"
text_to_num = require 'text-to-number'
templ = require "./templ"
Promise = require "promise"
async = require "async"

# given a skill and a phrase extract the data and the intent name
module.exports = (text, skill, callback) ->

  # for each intent, test whether the specified string matches
  async.map skill.intents, (int, done_intent) ->

    # get first truthy utterance (determine which utterance the user used)
    # TODO this could be made a lot more efficient
    utterances = _.chain(int.utterances).map (utt) =>
      templ.extract(utt) text
    .filter (a) =>
      if typeof a is 'object'
        a
      else
        false
    .value()

    # if there are utterances, return them
    # otherwise, try again with the next intent
    if utterances.length and data = utterances[0]
      done_intent null,
        utterances: data
        intent: int
    else
      done_intent null


  , (err, intents) ->
    # remove all the nulls from above
    intents = _.compact intents
   
    # there was a matching intent!
    if intents.length

      # shorten the two property values to make them easier to access
      int = intents[0].intent
      data = intents[0].utterances

      # coerse all data types to their proper values
      async.map Object.keys(int.templ), (k, done) =>
        v = int.templ[k]

        # a number, but in a textual format (like fifty five)
        # this is converted back to its numerical representation (like 55)
        if v.type.toString().indexOf("function Number()") isnt -1 and k of data and isNaN parseFloat data[k]
          data[k] = text_to_num data[k]
          done null

        # manual coersion (like Number('5') for example)
        else if k of data
          data[k] = v.type(data[k])

          # returned a promise?
          if data[k] instanceof Promise
            # wait for the promise, then continue looping
            data[k].then (resp) ->
              data[k] = resp
              done null
            .catch done
          else
            # didn't return a promise, so we're done.
            done null

        # not in the types list? remove it.
        else
          delete data[k]
          done null
      , (err) ->

        # validate metadata guards
        for k, v of data
          if int.templ[k] and int.templ[k].metadata

            # check to make sure that all `is_required` properies are in the data
            # example: "is_required": true
            if int.templ[k].metadata.is_required and data[k] is undefined
              return callback null

            # does each data element tested follow the specified format
            # example: "is_format": "[\w]+"
            if format = int.templ[k].metadata.is_format
              format_regex = new RegExp(format)
              r = format_regex.exec(v)
              return callback null if not r

        callback
          # send it out
          name: int.intent
          raw: text

          # a total workaround, but if something is in the utils skill then it's
          # global. (if it's said the context will switch to its skill from anywhere)
          flags: if skill.name is "utils" then global: true else []
          data: data
    else
      # no matching intent
      callback null
