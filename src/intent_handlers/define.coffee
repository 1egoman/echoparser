

exports.defineWord = (interaction, intent) ->

  interaction.search_wolfram "define #{intent.data.phrase}", (err, data) ->

    opts = data.split('\n').map (i) ->
      i.split('|').map (j) -> j = j.trim()

    interaction.form_response false,
      "a #{intent.data.phrase} could be " + opts.map((i) -> "a #{i[1]}, meaning #{i[2]};").join(' '),
      true
