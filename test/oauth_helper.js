var assert = require('assert');
var loadFile = require("./helpers").loadFile
var fs = require("fs"), path = require("path")

oauth_helper = loadFile("oauth_helper")


// ------------------------------------------------------------------------------
// Interaction
// The core concept used to describe an interchange of intents
// ------------------------------------------------------------------------------
cal_config_path = path.join("config", "oauth", "calendar.json")
describe('Oauth Helper', function() {
  describe('get_oauth_clients', function() {
    _this = this

      // put calendar token info within the oauth tokens folder to test that
      // below
      before(function(done) {
        fs.writeFile(cal_config_path, JSON.stringify({
          name: "calendar",
          token: "calendar_token"
        }), done)
      })

      // remove file when done
      after(function(done) {
        fs.unlink(cal_config_path, done)
      })

    it('successfully gets all intents', function(done) {
      oauth_helper.get_oauth_clients().then(function(data) {
        assert(data.length)
        assert.equal(typeof data[0], "object")
        assert.equal(typeof data[0].raw_name, "string")
        assert.equal(typeof data[0].name, "string")

        // make sure the calendar token is what was set above
        data.filter(function(i) {
          return i.name === "calendar"
        }).forEach(function(i) {
          assert.equal(i.token, "calendar_token")
        });

        done()
      });
    });

  });

  describe('save and read token', function() {
    _this = this

    it('save a token', function(done) {
      oauth_helper.save_token("test", "test token").then(function() {
        test = JSON.parse(fs.readFileSync(path.join("config", "oauth", "test.json")))
        assert.deepEqual(test, {
          name: "test",
          token: "test token"
        })
        done()
      })
    })

    it('read a token', function(done) {
      oauth_helper.read_token("test").then(function(data) {
        assert.deepEqual(data, {
          name: "test",
          token: "test token"
        })
        done()
      })
    })

  });

  describe('register token', function() {
    _this = this

    before(function() {
      oauth_helper.init_oauth_clients("http://callback_prefix.com")
    })

    it('successfully registers a token', function() {
      oauth_helper.register_token({
        params: {name: "calendar"},
        query: {code: "calendar_token"}
      }, {
        redirect: function(data) {
          assert.equal(data, "/oauth")
          done()
        }
      })
    })

    it('won\'t register a token with a bad id', function(done) {
      oauth_helper.register_token({
        params: {name: "test"}
      }, {
        "status": function(stat) {
          assert.equal(stat, 400)
          return {
            send: function(data) {
              assert.equal(data, "No such intent 'test'")
                done()
            }
          }
        }
      })
    })


  })

});
