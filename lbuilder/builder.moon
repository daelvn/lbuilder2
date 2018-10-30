-- lbuilder2 | 08.10.2018
-- By daelvn
-- Pattern builder
commons = require "lbuilder.commons"
meta    = require "lbuilder.meta"
utils   = require "lbuilder.utils"
import is_set from utils

-- Saves
saved = {}
save  = (any)  -> saved[any.name] = any if any
get   = (name) -> saved[name]       and (saved[name].tree and saved[name].tree or saved[name].value) or false
whole = (name) -> saved[name]       or false

-- wrap, unwrap
wrap    = (any) -> (value) -> if any.tree then any.tree = value else any.value = value
unwrap  = (any) ->            (any.tree and any.tree or any.value) if any

-- Atoms
local atom, generic, literal, normal, set
atom = (a, name, type, b) ->
  setmetatable {
    name:    name  or "?"
    type:    type  or "?"
    value:   a     or ""
    builder: b     or atom
  }, meta.atom
generic = (a, name, type) -> atom a,                    (name or ""), type,      generic
literal = (a, name)       -> atom (commons.sanitize a), (name or ""), "literal", literal
normal  = (a, name)       -> atom a,                    (name or ""), "normal",  normal
set     = (a, name)       -> atom a,                    (name or ""), "set",     set

-- element
local element
element = (...) ->
  setmetatable {
    name:    "?"
    type:    "element"
    tree:    [atom for i, atom in *{...}]
    builder: element
  }, meta.element

-- group
local group
group = (element) ->
  return setmetatable {
    name:    "?"
    type:    "group"
    builder: group
    value:   do
      _value = ""
      for i, atom in *element.tree
        switch atom.type
          when "literal" then _value ..= commons.sanitize atom.value
          else                _value ..= atom.value
      _value
  }, meta.group

-- Module
{
  -- Saves
  :saved, :save, :get, :whole
  -- Wrapping
  :wrap, :unwrap
  -- Atoms
  :atom, :literal, :normal, :set
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
