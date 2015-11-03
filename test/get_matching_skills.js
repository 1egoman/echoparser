var assert = require('assert');
var loadFile = require("./helpers").loadFile

SkillList = loadFile("echo_lib/skill_list")
GetMatchingSkills = loadFile("echo_lib/get_matching_skills")

describe("get_matching_skills", function() {
  var _this = this

// ------------------------------------------------------------------------------
// Pull in a sample skill/intent for testing
// Both build the list and convert the types to javascrpt-y types
// ------------------------------------------------------------------------------
  before(function() {
    skill_list = new SkillList("", false)
    _this.skills = skill_list.decode_skills([
      "testSkill.testIntent",
      "  foo {bar}",
      "  ---",
      "  bar: String",
    ].join('\n'))
    _this.skills = skill_list.unpack_intent_types(_this.skills)
  })

  it("retrives working matching skill for 'foo test'", function() {
    skill = GetMatchingSkills("foo test", _this.skills, function(skill) {
      assert.equal(skill.name, "testSkill.testIntent")
      assert.equal(skill.raw, "foo test")
      assert.deepEqual(skill.flags, [])
      assert.deepEqual(skill.data, {bar: "test"})
    })
  })

  // Won't pass yet. Have to fix `extract_from_skill` tests first.
  // it("won't work when data elements are missing", function() {
  //   skill = GetMatchingSkills("foo ", _this.skills)
  //   assert.equal(skill, null)
  // })

  it("won't work when no intents match", function() {
    skill = GetMatchingSkills("doesn't match", _this.skills, function(skill) {
      assert.equal(skill, null)
    })
  })

})
