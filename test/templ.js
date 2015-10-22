var assert = require('assert');
var loadFile = require("./helpers").loadFile

Templ = loadFile("echo_lib/templ")

describe("Templ", function() {

  describe("Assembling templates", function() {
    
// ------------------------------------------------------------------------------
// Try to use a bunch of different types in templates to make sure they all work
// ------------------------------------------------------------------------------
    types = {
      number: 1,
      date: new Date,
      string: "foo",
      array: [1, 2, 3, "foo"],
      object: {1: 2, 3: 4, "foo": "bar"},
      bool: true,
    }
    for (k in types) {
      it("can assemble a template with "+k, function() {
        finished = Templ.embed("foo {bar}")({bar: types[k]})
        assert.equal(finished, "foo "+types[k].toString())
      })
    }


// ------------------------------------------------------------------------------
// Make sure templates in all positions will work
// ------------------------------------------------------------------------------
    it("renders as last element", function() {
      finished = Templ.embed("foo {bar}")({bar: "baz"})
      assert.equal(finished, "foo baz")
    })

    it("renders as first element", function() {
      finished = Templ.embed("{bar} foo")({bar: "baz"})
      assert.equal(finished, "baz foo")
    })

    it("renders in middle", function() {
      finished = Templ.embed("foo {bar} baz")({bar: "hello"})
      assert.equal(finished, "foo hello baz")
    })

    it("renders in middle (no spaces)", function() {
      finished = Templ.embed("foo{bar}baz")({bar: "hello"})
      assert.equal(finished, "foohellobaz")
    })

// ------------------------------------------------------------------------------
// Nonexistant data renders with [none]
// ------------------------------------------------------------------------------
    it("renders nonexistant data with [none]", function() {
      finished = Templ.embed("foo {bar} baz")({})
      assert.equal(finished, "foo [none] baz")
    })

  })

  describe("Disassembling templates", function() {
    
// ------------------------------------------------------------------------------
// Try to use a bunch of different types in templates to make sure they all work
// ------------------------------------------------------------------------------
    types = {
      number: 1,
      date: new Date,
      string: "foo",
      array: [1, 2, 3, "foo"],
      object: {1: 2, 3: 4, "foo": "bar"},
      bool: true,
    }
    for (k in types) {
      (function(k) {
        it("can disassemble a template with "+k, function() {
          finished = Templ.extract("foo {bar}")("foo "+types[k].toString())
          assert.deepEqual(finished, {bar: types[k].toString()})
        })
      })(k)
    }

  })

})
