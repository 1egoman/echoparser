var assert = require('assert');

// load a file to test
loadFile = function(file) {
  console.log("... Loading "+file)
  return require("../dist/"+file);
}

Interaction = loadFile("interaction")

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



  describe('form_response', function() {
    _this = this

    // create a new interaction
    before(function() {
      _this.interaction = new Interaction()
    })

    // the interaction starts emty
    it('correctly sends out a response with correct data', function(done) {
      _this.interaction.on("intent_response", function(data) {
        assert.equal(data.outputSpeach.text, "response text")
        done()
      })
      _this.interaction.form_response(false, "response text", false)
    });

  });

});

