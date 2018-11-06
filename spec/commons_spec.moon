-- lbuilder | commons.moon testing
-- By daelvn
commons = require "lbuilder.commons"
--dbg     = io.open "log.txt", "a+"


-- Sanitizing
describe "sanitizing", ->
  import sanitize from commons
  it "sanitizes a pattern #sanitize", ->
    s = "[]()%a."
    assert.are_equal "%[%]%(%)%%a%.", sanitize s

-- Atomizing
describe "atomizing", ->
  import atomize from commons
  it "atomizes a pattern #atomize", ->
    s = "ab+[xyz]?"
    assert.are_same { "a", "b+", "[xyz]?" }, atomize s

-- Negation
describe "negation", ->
  import negate_pattern, negate_set from commons
  it "negates a pattern #negate_pattern", ->
    sp = "ab"
    sn = "[^a][^b]"
    assert.are_equal sn, negate_pattern sp
    assert.are_equal sp, negate_pattern sn
  it "negates a set #negate_set", ->
    sp = "[ab]"
    sn = "[^ab]"
    assert.are_equal sn, negate_set sp
    assert.are_equal sp, negate_set sn

-- Tables
describe "tables", ->
  import copy, merge, multi from commons
  it "copies a table #copy", ->
    t = {
      [1]: "x"
      [2]: {
        [1]: "y"
      }
    }
    tc = copy t
    assert.are_same t, tc
  it "merges two tables #merge", ->
    ta = {
      [1]: "x"
      [2]: "y"
    }
    tb = {
      [1]: "z"
      [3]: "n"
    }
    assert.are_same {
      [1]: "z"
      [2]: "y"
      [3]: "n"
    }, merge ta, tb
  it "sets several keys for a table #multi", ->
    t = {
      "x,y": "a"
      "z,n": "b"
    }
    local tf
    tf = {
      x: "a"
      y: "a"
      z: "b"
      n: "b"
    }
    assert.are_same tf, multi t

-- Joining
describe "joining", ->
  import join_sets from commons
  it "joins two sets #join", ->
    assert.are_equal "[ab]", join_sets "[a]", "[b]"

--dbg\close!
