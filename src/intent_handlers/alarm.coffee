moment = require "moment"

# the user sets an alarm / timer
# if the device can do its own alarm (specified in request metadata)
# then let it, otherwise just send an additional request later to "trigger"
# the alarm
exports.setAlarm = exports.setTimer = (interaction, intent) ->
  alarm_msg = "Setting alarm for #{moment(intent.data.time).format('MMMM Do [at] h:mm a')}."

  # the system has something that can handle an alarm attached
  if "doesLocalAlarm" in interaction.metadata.capabilities
    interaction.raw_response
      outputSpeach:
        type: "PlainText"
        text: alarm_msg

      # pass alarm data to be handled locally
      outputContent: [
        type: "AudioAlarm",
        data: {
          triggerAt: intent.data.time.toISOString(),
          alarmSound: "beep"
        }
      ]

      shouldEndSession: true

  else
    interaction.form_response false, alarm_msg, false

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

exports.timeRemaining = (interaction, intent) ->

  has_alarm = (err, alarm) ->
    interaction.form_response \
      false,
      "#{moment(alarm.triggerAt).fromNow().replace('ago', '')} left.",
      true

  if alarm = interaction.metadata.alarm_remaining
    has_alarm null, alarm
  else
    interaction.request_metadata ["alarm_remaining"]
    interaction.await_response {}, has_alarm
