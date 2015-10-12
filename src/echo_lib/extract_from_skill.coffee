_ = require "underscore"
text_to_num = require 'text-to-number'
templ = require "./templ"

# given a skill and a phrase extract the data and the intent name
module.exports = (text, skill) ->
  # for each intent, test whether the specified string matches
  intents = for int in skill.intents

    # get first truthy utterance (determine which utterance the user used)
    # TODO this could be made a lot more efficient
    data = _.chain(int.utterances).map (utt) =>
      templ.extract(utt) text
    .find (a) => a
    .value()


    if data
      name: int.intent

      # a total workaround, but if something is in the utils skill then it's
      # global. (if it's said the context will switch to its skill from anywhere)
      flags: if int.intent.indexOf("util") is 0 then global: true else []
      data: do (data) =>
        # coerse all data types to their proper values
        _.mapObject int.templ, (v, k) =>

          # a number, but in a textual format (like fifty five)
          # this is converted back to its numerical representation (like 55)
          if v.type.toString().indexOf("function Number()") isnt -1 and k of data and isNaN parseFloat data[k]
            data[k] = text_to_num data[k]

          # manual coersion (like Number('5') for example)
          else if k of data
            data[k] = v.type(data[k])

          # not in the types list? remove it.
          else delete data[k]
        data
    else
      null
  
  intents.length and _.compact(intents)[0] or null # return first element or null

