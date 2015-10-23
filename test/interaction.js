var assert = require('assert');
var loadFile = require("./helpers").loadFile

Interaction = loadFile("interaction")


// ------------------------------------------------------------------------------
// Interaction
// The core concept used to describe an interchange of intents
// ------------------------------------------------------------------------------
describe('Interaction', function() {
  describe('constructor', function() {
    _this = this

    // create a new interaction
    before(function() {
      _this.interaction = new Interaction()
    })

    // remove all listeners between each test
    beforeEach(function() {
      _this.interaction.removeAllListeners("intent_response")
    })


    it('has no intents', function() {
      assert.equal(_this.interaction.intents.length, 0)
    });

    it('has empty state', function() {
      assert.equal(Object.keys(_this.interaction.remote.state).length, 0)
    });

    it('has an id', function() {
      assert.equal(typeof _this.interaction.id, "string")
    });

  });



// ------------------------------------------------------------------------------
// form_response
// A intent sends data to be sent back to the device (and the user)
// ------------------------------------------------------------------------------
  describe('form_response', function() {
    _this = this

    // create a new interaction
    before(function() {
      _this.interaction = new Interaction({debug: false})
    })

    // remove all listeners between each test
    beforeEach(function() {
      _this.interaction.removeAllListeners("intent_response")
    })


    it('correctly sends out a response with correct data', function(done) {
      _this.interaction.once("intent_response", function(data) {
        assert.equal(data.outputSpeach.text, "response text")
        assert.equal(data.outputSpeach.type, "PlainText")
        assert.equal(data.shouldEndSession, false)
        done()
      })
      _this.interaction.form_response(false, "response text", false)
    });

    it('respects shouldEndSession', function(done) {
      _this.interaction.once("intent_response", function(data) {
        assert.equal(data.outputSpeach.text, "response text")
        assert.equal(data.outputSpeach.type, "PlainText")
        assert.equal(data.shouldEndSession, true)
        done()
      })
      _this.interaction.form_response(false, "response text", true)
    });

    it('respects shouldEndSession: if null, become false', function(done) {
      _this.interaction.once("intent_response", function(data) {
        assert.equal(data.outputSpeach.text, "response text")
        assert.equal(data.outputSpeach.type, "PlainText")
        assert.equal(data.shouldEndSession, false)
        done()
      })
      _this.interaction.form_response(false, "response text", null)
    });


  });




// ------------------------------------------------------------------------------
// end_response
// Stop the response and send nothing.
// ------------------------------------------------------------------------------
  describe('end_response', function() {
    _this = this

    // create a new interaction
    before(function() {
      _this.interaction = new Interaction({debug: false})
    })

    // remove all listeners between each test
    beforeEach(function() {
      _this.interaction.removeAllListeners("intent_response")
    })


    it('ends response', function(done) {
      _this.interaction.once("intent_response", function(data) {
        assert.equal(data.outputSpeach, null)
        assert.equal(data.shouldEndSession, true)
        done()
      })
      _this.interaction.end_response()
    });

  });




// ------------------------------------------------------------------------------
// raw_response
// Send back exactly what we say, used underneath all the other *_response stuff
// ------------------------------------------------------------------------------
  describe('raw_response', function() {
    _this = this

    // create a new interaction
    before(function() {
      _this.interaction = new Interaction({debug: false})
    })

    // remove all listeners between each test
    beforeEach(function() {
      _this.interaction.removeAllListeners("intent_response")
    })

    it('accepts an object correctly formatted', function(done) {
      _this.interaction.once("intent_response", function(data) {
        assert.equal(data.outputSpeach.text, "response text")
        assert.equal(data.outputSpeach.type, "PlainText")
        assert.equal(data.shouldEndSession, false)
        done()
      })
      _this.interaction.raw_response({
        outputSpeach: {
          type: "PlainText",
          text: "response text"
        },
        shouldEndSession: false
      })
    });

    it('will return false if passed something not an object', function() {
      _this.interaction.once("intent_response", function(data) {
        throw new Error("Send a response when it was sent bogus data.")
      })

      // test a bunch of things to make sure they all return false
      choices = [1, null, "string", undefined, 0]
      choices.forEach(function(bogus) {
        assert.equal(_this.interaction.raw_response(bogus), false)
      })
    });

    it('correctly puts audio into remote playlist', function(done) {
      _this.interaction.once("intent_response", function(data) {
        assert.equal(data.outputSpeach.text, "response text")
        assert.equal(data.outputSpeach.type, "PlainText")
        assert.equal(data.shouldEndSession, false)

        // audio was put into the playlist
        assert.deepEqual(_this.interaction.remote.playlist, [data.outputAudio])
        done()
      })
      _this.interaction.raw_response({
        outputSpeach: {
          type: "PlainText",
          text: "response text"
        },
        outputAudio: {
          type: "AudioLink",
          src: "http://dummy.url/track.mp3"
        },
        shouldEndSession: false
      })
    });

    it('correctly puts actions into remote', function(done) {
      _this.interaction.once("intent_response", function(data) {
        assert.equal(data.outputSpeach.text, "response text")
        assert.equal(data.outputSpeach.type, "PlainText")
        assert.equal(data.shouldEndSession, false)

        // actions were put into remote
        assert.deepEqual(_this.interaction.remote.state, {"real.action":{state: true}})
        done()
      })
      _this.interaction.raw_response({
        outputSpeach: {
          type: "PlainText",
          text: "response text"
        },
        actions: {
          "real.action": { state: true },
          "empty.action": null // null = not added
        },
        shouldEndSession: false
      })
    });

  });


// ------------------------------------------------------------------------------
// await_response
// wait for a new intent to come in on the interaction
// ------------------------------------------------------------------------------
  describe("await_response", function() {


    // create a new interaction
    before(function() {
      _this.interaction = new Interaction({debug: false})
    })

    // remove all listeners between each test
    beforeEach(function() {
      _this.interaction.removeAllListeners("intent_response")
    })

    it('listens for a response and calls back that response', function(done) {
      // our incoming response
      intent = {
        outputSpeach: {
          type: "PlainText",
          text: "Hello, World!"
        },
        shouldEndSession: false
      }

      _this.interaction.await_response({}, function(err, risen_intent) {
        assert.equal(err, null)
        assert.deepEqual(risen_intent, intent)
        done()
      })
      // pretend to be an incoming response from a user
      _this.interaction.emit("intent", intent)
    })

    it('will still work with an empty opts for await_reponse', function(done) {
      // our incoming response
      intent = {
        outputSpeach: {
          type: "PlainText",
          text: "Hello, World!"
        },
        shouldEndSession: false
      }

      _this.interaction.await_response(null, function(err, risen_intent) {
        assert.equal(err, null)
        assert.deepEqual(risen_intent, intent)
        done()
      })
      // pretend to be an incoming response from a user
      _this.interaction.emit("intent", intent)
    })

  })


// ------------------------------------------------------------------------------
// format_intent
// add the interaction id to an intent before being sent out
// ------------------------------------------------------------------------------
  describe("format_intent", function() {


    // create a new interaction
    before(function() {
      _this.interaction = new Interaction({debug: false})
    })

    // remove all listeners between each test
    beforeEach(function() {
      _this.interaction.removeAllListeners("intent_response")
    })

    it('adds interaction id to an intent', function() {
      formatted = _this.interaction.format_intent({
        outputSpeach: {
          type: "PlainText",
          text: "Hello, World!"
        },
        shouldEndSession: false
      })

      assert.equal(formatted.interactionId, _this.interaction.id)
    })
  })


// ------------------------------------------------------------------------------
// search_wolfram
// search wolfram alpha for a query
// ------------------------------------------------------------------------------
  describe("search_wolfram", function() {


    // create a new interaction
    before(function() {
      _this.interaction = new Interaction({debug: false})
    })

    // remove all listeners between each test
    beforeEach(function() {
      _this.interaction.removeAllListeners("intent_response")
    })

    it('makes sure there\'s a WOLFRAM_APP_KEY env variable', function() {
      assert(process.env.WOLFRAM_APP_KEY) // truthy
    })

    it('querys wolfram for the time, looks for hours, minutes, and seconds, using a callback', function(done) {
      this.timeout(10000) // could take a while
      this.slow(3000) // more of the same /\
      _this.interaction.search_wolfram("time", function(err, data) {
        date = new Date()

        // look for hours
        hours = date.getHours() % 12
        assert.notEqual(data.indexOf(hours), -1)

        // look for minutes
        min = date.getMinutes()
        assert.notEqual(data.indexOf(min), -1)

        // look for am/pm
        merid = date.getHours() > 12 ? "pm" : "am"
        assert.notEqual(data.indexOf(merid), -1)

        done()
      })
    })

    it('querys wolfram for the time, looks for hours, minutes, and seconds, and sends as a response', function(done) {
      this.timeout(10000) // could take a while
      this.slow(3000) // more of the same /\
      _this.interaction.on("intent_response", function(data) {
        // look for hours
        hours = new Date().getHours() % 12
        assert.notEqual(data.outputSpeach.text.indexOf(hours), -1)

        // look for minutes
        min = new Date().getMinutes()
        assert.notEqual(data.outputSpeach.text.indexOf(min), -1)

        // look for am/pm
        merid = new Date().getHours() > 12 ? "pm" : "am"
        assert.notEqual(data.outputSpeach.text.indexOf(merid), -1)

        done()
      })
      _this.interaction.search_wolfram("time", undefined, false)
    })

  })


// ------------------------------------------------------------------------------
// audio_response
// Send an audio file payload in the response
// ------------------------------------------------------------------------------
  describe('audio_response', function() {
    _this = this

    // create a new interaction
    before(function() {
      _this.interaction = new Interaction({debug: false})
    })

    // remove all listeners between each test
    beforeEach(function() {
      _this.interaction.removeAllListeners("intent_response")
    })

    it('will return false if passed something not an object', function() {
      _this.interaction.once("intent_response", function(data) {
        throw new Error("Send a response when it was sent bogus data.")
      })

      // test a bunch of things to make sure they all return false
      choices = [1, null, "string", undefined, 0]
      choices.forEach(function(bogus) {
        assert.equal(_this.interaction.audio_response(false, bogus), false)
      })
    });

    it('puts the audio track in the response', function(done) {
      _this.interaction.once("intent_response", function(data) {
        assert.equal(data.outputAudio.src, "http://dummy.url/track.mp3")
        assert.equal(data.outputAudio.type, "AudioLink")
        assert.equal(data.outputAudio.name, "Song Title")
        assert.equal(data.shouldEndSession, false)

        // audio was put into the playlist, too
        assert.deepEqual(_this.interaction.remote.playlist, [data.outputAudio])
        done()
      })
      _this.interaction.audio_response(false, {
        name: "Song Title",
        src: "http://dummy.url/track.mp3"
      })
    });

    it('audio_response with outputSpeach', function(done) {
      _this.interaction.once("intent_response", function(data) {
        assert.equal(data.outputAudio.src, "http://dummy.url/track.mp3")
        assert.equal(data.outputAudio.type, "AudioLink")
        assert.equal(data.outputAudio.name, "Song Title")
        assert.equal(data.outputSpeach.text, "Hello World!")
        assert.equal(data.shouldEndSession, false)

        // audio was put into the playlist, too
        assert.deepEqual(_this.interaction.remote.playlist, [data.outputAudio])
        done()
      })
      _this.interaction.audio_response(false, {
        name: "Song Title",
        src: "http://dummy.url/track.mp3"
      }, "Hello World!")
    });

    it('audio_response that ends session', function(done) {
      _this.interaction.once("intent_response", function(data) {
        assert.equal(data.outputAudio.src, "http://dummy.url/track.mp3")
        assert.equal(data.outputAudio.type, "AudioLink")
        assert.equal(data.outputAudio.name, "Song Title")
        assert.equal(data.shouldEndSession, true)

        // audio was put into the playlist, too
        assert.deepEqual(_this.interaction.remote.playlist, [data.outputAudio])
        done()
      })
      _this.interaction.audio_response(false, {
        name: "Song Title",
        src: "http://dummy.url/track.mp3"
      }, undefined, true)
    });

  });



// ------------------------------------------------------------------------------
// audio_playlist_response
// Send an audio playlist payload in the response
// ------------------------------------------------------------------------------
  describe('audio_playlist_response', function() {
    _this = this

    // create a new interaction
    before(function() {
      _this.interaction = new Interaction({debug: false})
    })

    // remove all listeners between each test
    beforeEach(function() {
      _this.interaction.removeAllListeners("intent_response")
    })

    it('will return false if passed something not an object', function() {
      _this.interaction.once("intent_response", function(data) {
        throw new Error("Send a response when it was sent bogus data.")
      })

      // test a bunch of things to make sure they all return false
      choices = [1, null, "string", undefined, 0]
      choices.forEach(function(bogus) {
        assert.equal(_this.interaction.audio_playlist_response(false, bogus), false)
      })
    });

    it('puts the audio playlist in the response', function(done) {
      _this.interaction.once("intent_response", function(data) {
        assert.equal(data.outputAudio.type, "AudioLinkPlaylist")
        assert.equal(data.outputAudio.playlist[0].src, "http://dummy.url/track.mp3")
        assert.equal(data.outputAudio.playlist[0].name, "Song Title")
        assert.equal(data.shouldEndSession, false)

        // audio was put into the playlist, too
        assert.deepEqual(_this.interaction.remote.playlist, data.outputAudio.playlist)
        done()
      })
      _this.interaction.audio_playlist_response(false, [{
        name: "Song Title",
        src: "http://dummy.url/track.mp3"
      }])
    });

    it('audio_response with outputSpeach', function(done) {
      _this.interaction.once("intent_response", function(data) {
        assert.equal(data.outputAudio.type, "AudioLinkPlaylist")
        assert.equal(data.outputAudio.playlist[0].src, "http://dummy.url/track.mp3")
        assert.equal(data.outputAudio.playlist[0].name, "Song Title")
        assert.equal(data.outputSpeach.text, "Hello World!")
        assert.equal(data.shouldEndSession, false)

        // audio was put into the playlist, too
        assert.deepEqual(_this.interaction.remote.playlist, data.outputAudio.playlist)
        done()
      })
      _this.interaction.audio_playlist_response(false, [{
        name: "Song Title",
        src: "http://dummy.url/track.mp3"
      }], "Hello World!")
    });

    it('audio_playlist_response that ends session', function(done) {
      _this.interaction.once("intent_response", function(data) {
        assert.equal(data.outputAudio.type, "AudioLinkPlaylist")
        assert.equal(data.outputAudio.playlist[0].src, "http://dummy.url/track.mp3")
        assert.equal(data.outputAudio.playlist[0].name, "Song Title")
        assert.equal(data.outputSpeach.text, "Hello World!")
        assert.equal(data.shouldEndSession, true)

        // audio was put into the playlist, too
        assert.deepEqual(_this.interaction.remote.playlist, data.outputAudio.playlist)
        done()
      })
      _this.interaction.audio_playlist_response(false, [{
        name: "Song Title",
        src: "http://dummy.url/track.mp3"
      }], "Hello World!", true)
    });




  });


});

