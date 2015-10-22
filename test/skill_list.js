var assert = require('assert');
var loadFile = require("./helpers").loadFile

SkillList = loadFile("echo_lib/skill_list")

describe("Skill List", function() {

  var _this = this

  // create a new skill list
  // the false will keep the class from trying to pull in skills so we can
  // feed it stuff for testing
  beforeEach(function() {
    _this.skill_list = new SkillList('', false)
  })

  describe("Parsing skill templates", function() {
    
    it("parses a one skill, one utterance intent", function() {
      skill = _this.skill_list.decode_skills([
        "testSkill.testIntent",
        "  foo {bar}",
        "  ---",
        "  bar: String",
      ].join('\n'))[0]

      assert.equal(skill.name, "testSkill")
      assert.deepEqual(skill.intents, [{
        intent: "testIntent",
        utterances: [
          "foo {bar}",
        ],
        templ: {
          bar: {
            type: "String"
          }
        }
      }])
    })

    it("parses a one skill, two utterance intent", function() {
      skill = _this.skill_list.decode_skills([
        "testSkill.testIntent",
        "  foo {bar}",
        "  baz {bar}",
        "  ---",
        "  bar: String",
      ].join('\n'))[0]

      assert.equal(skill.name, "testSkill")
      assert.deepEqual(skill.intents, [{
        intent: "testIntent",
        utterances: [
          "foo {bar}",
          "baz {bar}",
        ],
        templ: {
          bar: {
            type: "String"
          }
        }
      }])
    })

    it("parses a two intent skill", function() {
      skill = _this.skill_list.decode_skills([
        "testSkill.testIntent",
        "  foo {bar}",
        "  baz {bar}",
        "  ---",
        "  bar: String",
        "",
        "testSkill.testIntentTwo",
        "  yo {place}",
        "  hello {place}",
        "  ---",
        "  place: String",
      ].join('\n'))[0]

      assert.equal(skill.name, "testSkill")
      assert.deepEqual(skill.intents, [{
        intent: "testIntent",
        utterances: [
          "foo {bar}",
          "baz {bar}"
        ],
        templ: {
          bar: {
            type: "String"
          }
        }
      }, {
        intent: "testIntentTwo",
        utterances: [
          "yo {place}",
          "hello {place}"
        ],
        templ: {
          place: {
            type: "String"
          }
        }
      }])
    })

    it("parses two intents, with whitespace everywhere", function() {
      skill = _this.skill_list.decode_skills([
        "testSkill.testIntent  ",
        "  foo {bar} ",
        "  baz {bar}  ",
        "  ---   ",
        "  bar: String       ",
        "  ",
        "",
        "testSkill.testIntentTwo",
        "  yo {place}",
        "  hello {place}",
        "  ---",
        "  place: String",
      ].join('\n'))[0]

      assert.equal(skill.name, "testSkill")
      assert.deepEqual(skill.intents, [{
        intent: "testIntent",
        utterances: [
          "foo {bar}",
          "baz {bar}"
        ],
        templ: {
          bar: {
            type: "String"
          }
        }
      }, {
        intent: "testIntentTwo",
        utterances: [
          "yo {place}",
          "hello {place}"
        ],
        templ: {
          place: {
            type: "String"
          }
        }
      }])
    })
  })

  describe("can handle types for the template", function() {
    types = ["Number", "String"] // TODO More types?
    types.forEach(function(type) {
      it("can handle type in templ: "+type, function() {

        skill = _this.skill_list.decode_skills([
          "testSkill.testIntent",
          "  foo {bar}",
          "  ---",
          "  bar: "+type,
        ].join('\n'))[0]

        assert.equal(skill.name, "testSkill")
        assert.deepEqual(skill.intents, [{
          intent: "testIntent",
          utterances: [
            "foo {bar}",
          ],
          templ: {
            bar: {
              type: type
            }
          }
        }])
      })
    })
  })

})
