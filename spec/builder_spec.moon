-- lbuilder2 | builder.moon tests
builder = require "lbuilder.builder"
utils   = require "lbuilder.utils"

import wrap, unwrap from builder

TODO = "todo"

describe "atoms", ->
  import atom, generic, literal, normal, set from builder
  it "defines an atom #atom", ->
    a = atom "a", "Name", "?"
    assert.are_equal "a", unwrap a
  it "defines a generic atom #generic", ->
    g = generic "g", "Name"
    assert.are_equal "g", unwrap g
  it "defines a literal atom #literal", ->
    l = literal "l", "Name"
    assert.are_equal "l", unwrap l
  it "defines a normal atom #normal", ->
    n = normal "n", "Name"
    assert.are_equal "n", unwrap n
  it "defines a set atom #set", ->
    s = set "s", "Name"
    assert.are_equal "s", unwrap s
  
  describe "atom operations", ->
    it "names atoms #atom_label", ->
      l = literal "a"
      l "Name2"
      assert.are_equal "Name2", l.name
    it "joins atoms #atom_join", ->
      l1 = literal "v"
      l2 = literal "n"
      assert.are_equal "vn", unwrap (l1 + l2)
    it "repeats atoms #atom_repeat", -> pending TODO
    it "repeats atoms with limit #atom_limit", -> pending TODO
    it "modifies atoms #atom_modify", -> pending TODO
    it "combines atoms #atom_combine", -> pending TODO
    it "negates atoms #atom_negate", -> pending TODO
    it "copies atoms #atom_copy", -> pending TODO
    it "turns atoms into elements #atom_toelement", -> pending TODO
    it "compiles atoms #atom_compile", -> pending TODO

describe "elements", ->
  import element from builder
  it "defines an element #element", -> pending TODO
  
  describe "element operations", ->
    it "names elements #element_label", -> pending TODO
    it "applies a function to elements #element_apply", -> pending TODO
    it "selects an atom from elements #element_select", -> pending TODO
    it "transforms elements #element_transform", -> pending TODO
    it "joins elements #element_join", -> pending TODO
    it "combines elements #element_combine", -> pending TODO
    it "compiles elements #element_compile", -> pending TODO

describe "groups", ->
  import group from builder
  it "defines a group #group", -> pending TODO

  describe "group operations", ->
    it "names groups #group_names", -> pending TODO
    it "joins groups #group_joins", -> pending TODO
    it "tests groups #group_tests", -> pending TODO
    it "counts groups #group_counts", -> pending TODO
    it "matches groups #group_match", -> pending TODO

  describe "group iterations", ->
    it "iterates over the matches of groups #group_gmatch", -> pending TODO

  describe "group replacements", ->
    it "simple replaces groups #groups_replace", -> pending TODO
    it "div-replaces groups #groups_divreplace", -> pending TODO

describe "saves", ->
  import saved, save, get, whole from builder
  it "saves something #save", -> pending TODO
  it "gets the value of something saved #get", -> pending TODO
  it "fetches something saved #whole", -> pending TODO
