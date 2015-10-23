var assert = require('assert');
var loadFile = require("./helpers").loadFile

SkillList = loadFile("echo_lib/skill_list")
ExtractFromSkill = loadFile("echo_lib/extract_from_skill")

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
      "  bar: Number",
      "",
      "testSkill.testIntentPlace",
      "  hi {place}",
      "  hello {place}",
      "  ---",
      "  place: String",
      "  notInTemplate: String",

      // note: this is in a seperate "skill" - ie, _this.skills[1]
      "",
      "utils.testUtilsGlobal",
      "  is global",
      "  ---",
    ].join('\n'))
    _this.skills = skill_list.unpack_intent_types(_this.skills)
    _this.skill = _this.skills[0] // only one skill to test with
  })

  it("retrives working matching intent for 'hi test'", function() {
    skill = ExtractFromSkill("hi test", _this.skill)

    assert.equal(skill.name, "testIntentPlace")
    assert.equal(skill.raw, "hi test")
    assert.deepEqual(skill.flags, [])
    assert.deepEqual(skill.data, {place: "test"})
  })

  it("parses numbers in a special way", function() {
    skill = ExtractFromSkill("foo one", _this.skill)

    assert.equal(skill.name, "testIntent")
    assert.equal(skill.raw, "foo one")
    assert.deepEqual(skill.flags, [])
    assert.deepEqual(skill.data, {bar: 1})
  })

// ------------------------------------------------------------------------------
// Make sure that variables not present in the query aren't in the output data
// In this case, notInTemplate isn't in skill.data
// ------------------------------------------------------------------------------
  it("doesn't contain eronious template variables", function() {
    skill = ExtractFromSkill("hi world", _this.skill)

    assert.equal(skill.name, "testIntentPlace")
    assert.equal(skill.raw, "hi world")
    assert.deepEqual(skill.flags, {})
    assert.deepEqual(skill.data, {place: "world"})
  })

  it("retrives working matching intent for 'hi test'", function() {
    skill = ExtractFromSkill("is global", _this.skills[1])

    assert.equal(skill.name, "testUtilsGlobal")
    assert.equal(skill.raw, "is global")
    assert.deepEqual(skill.flags, {global: true})
    assert.deepEqual(skill.data, {})
  })


  it("won't match something that doesn't match at all", function() {
    skill = ExtractFromSkill("doesn't match", _this.skill)
    assert.equal(skill, null)
  })



})
