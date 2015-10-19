var assert = require('assert');

// load a file to test
loadFile = function(file) {
  console.log("... Loading "+file)
  return require("../dist/"+file);
}

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


});

