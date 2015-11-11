Twit = require "twit"
T = new Twit
  consumer_key: "bBXzfmpL8dSQ6YvUYuMzwNcAM"
  consumer_secret: "YJS2dI8Zi04iVuFc81Wbtw69kLxLy9XWnCK8iyKwZ9Fl6qvWQd"
  access_token: "2551037264-QGnrbqLGa43SkloGYvXnWa8kU9UQ4WcycjQaYhW"
  access_token_secret: "MYbNjtcQshcX7CCfsmIYZhzz8d0g8qh1n8IrQwWV9qAjX"

sendTweet = (interaction, intent) ->
  interaction.form_response false, "wip", true
