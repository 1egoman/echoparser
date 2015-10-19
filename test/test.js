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
// form_response
// A intent sends data to be sent back to the device (and the user)
// ------------------------------------------------------------------------------
  describe('form_response', function() {
    _this = this

    // create a new interaction
    before(function() {
      _this.interaction = new Interaction({debug: false})
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



});

