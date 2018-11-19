-- lbuilder2 | 08.10.2018
-- By daelvn
-- Pattern builder
commons = require "lbuilder.commons"
meta    = require "lbuilder.meta"
inspect = require "inspect"
log     = require "log"

-- Saves
saved = {}
save  = (any)  -> saved[any.name] = any if any
get   = (name) -> saved[name]       and (saved[name].tree and saved[name].tree or saved[name].value) or false
whole = (name) -> saved[name]       or false

-- wrap, unwrap
wrap    = (any) -> (value) -> if any.tree then any.tree = value else any.value = value
unwrap  = (any) ->            if (type any == "table") then (any.tree and any.tree or any.value) else any

-- Atoms
_atom = (a, name, type) ->
  setmetatable {
    name:    name  or "?"
    type:    type  or "?"
    value:   a     or ""
  }, meta.atom
_generic = (a, name, type) -> _atom a,                    (name or ""), (type or "generic")
_literal = (a, name)       -> _atom (commons.sanitize a), (name or ""), "literal"
_normal  = (a, name)       -> _atom a,                    (name or ""), "normal"
_set     = (a, name)       -> _atom a,                    (name or ""), "set"

-- element
_element = (...) ->
  setmetatable {
    name:    "?"
    type:    "element"
    tree:    [atom for atom in *{...}]
  }, meta.element

-- group
group = (element) ->
  return setmetatable {
    name:    "?"
    type:    "group"
    value:   do
      _value = ""
      for i, atom in pairs element.tree
        switch atom.type
          when "literal" then _value ..= commons.sanitize atom.value
          else                _value ..= atom.value
      _value
  }, meta.group

-- Atom for_builders
local atom, generic, literal, normal, set, element
atom    = (a, name, type) -> with _atom a, name, type
  .builder     = atom
  .for_atom    = atom
  .for_generic = generic
  .for_literal = literal
  .for_normal  = normal
  .for_set     = set
  .for_element = element
  .for_group   = group
generic = (a, name, type) -> with _generic a, name, type
  .builder     = generic
  .for_atom    = atom
  .for_generic = generic
  .for_literal = literal
  .for_normal  = normal
  .for_set     = set
  .for_element = element
  .for_group   = group
literal = (a, name) ->
  log.debug inspect a
  with _literal a, name
    .builder     = literal
    .for_atom    = atom
    .for_generic = generic
    .for_literal = literal
    .for_normal  = normal
    .for_set     = set
    .for_element = element
    .for_group   = group
normal  = (a, name) -> with _normal a, name
  .builder     = normal
  .for_atom    = atom
  .for_generic = generic
  .for_literal = literal
  .for_normal  = normal
  .for_set     = set
  .for_element = element
  .for_group   = group
set     = (a, name) -> with _set a, name
  .builder     = set
  .for_atom    = atom
  .for_generic = generic
  .for_literal = literal
  .for_normal  = normal
  .for_set     = set
  .for_element = element
  .for_group   = group
element = (...)  -> with _element ...
  .builder     = element
  .for_atom    = atom
  .for_generic = generic
  .for_literal = literal
  .for_normal  = normal
  .for_set     = set
  .for_element = element
  .for_group   = group

-- Module
{
  -- Saves
  :saved, :save, :get, :whole
  -- Wrapping
  :wrap, :unwrap
  -- Atoms
  :atom, :generic, :literal, :normal, :set
  -- Element
  :element
  -- Groups
  :group
  -- Constants
  most:     "+"
  least:    "-"
  any:      "*"
  optional: "?"
}
