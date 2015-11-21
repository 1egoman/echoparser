moment = require "moment"

# the user sets an alarm / timer
# TODO this won't work until remote stuff is persisted across interactions
exports.setAlarm = exports.setTimer = (interaction, intent) ->
  interaction.form_response false, "Setting alarm for #{moment(intent.data.time).format('MMMM Do [at] h:mm a')}.", true

  # set a timeout and wait those seconds
  setTimeout ->
    # update the ringing state
    interaction.raw_response
      events: [
        name: "alarm.ring"
        data:
          state: true
      ]
  , intent.data.time.getTime() - new Date().getTime()


# snooze the alarm
# TODO this won't work until remote stuff is persisted across interactions
exports.snooze = (interaction, intent) ->
  # is alarm on?
  if interaction.remote.state["alarm_ringing"]?.state

    # turn off the ringing
    interaction.raw_response
      events: [
        name: "alarm.ring"
        data:
          state: false
      ]

    # check for the snooze duration
    if intent.data.duration
      interaction.form_response false, "Snoozing until #{intent.data.duration}.", true
      setTimeout ->
        # update the ringing state
        interaction.raw_response
          events: [
            name: "alarm.ring"
            data:
              state: true
          ]
      , intent.data.duration.getTime() - new Date().getTime()

    else
      interaction.form_response false, "Snoozing for 5 minutes.", true
      setTimeout ->
        # update the ringing state
        interaction.raw_response
          events: [
            name: "alarm.ring"
            data:
              state: true
          ]
      , 300000 # five minutes in milliseconds
  else
    interaction.form_response false, "No alarm is set.", true

