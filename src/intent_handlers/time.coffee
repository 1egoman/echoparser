Interaction = require "../interaction"

# get current time
# take wolfram's expected output and pipe it through our own stuff
exports.getCurrentTime = (interaction, intent) ->
  interaction.search_wolfram "what time is it", (err, phrase) ->

    interaction.form_response true, do (phrase) ->
      datetime = phrase.split('|').map (i) -> i.trim()
      if datetime.length is 2
        [time, date] = datetime
        "It is currently #{time}."

      else
        # otherwise, just return what we got originally...
        phrase


# get current time at a specified place
# take wolfram's expected output and pipe it through our own stuff
exports.getCurrentTimeAtLocation = (interaction, intent) ->
  interaction.search_wolfram "what time is it in #{intent.data.where}", (err, phrase) ->

    interaction.form_response true, do (phrase) ->
      datetime = phrase.split('|').map (i) -> i.trim()
      if datetime.length is 2
        [time, date] = datetime
        """
        It is currently 
        #{time}, 
        #{date} in 
        #{intent.data.where[0].toUpperCase()}#{intent.data.where.slice(1)}.
        """.replace /\n/g, ''

      else
        # otherwise, just return what we got originally...
        phrase
