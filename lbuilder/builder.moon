-- lbuilder2 | 08.10.2018
-- By daelvn
-- Pattern builder

commons = require "lbuilder.commons"

-- TODO FIX non-compiling particles
-- TODO FIX non-defining groups
-- TODO FIX non-joining groups
-- TODO FIX group testing
-- TODO FIX THE FUCKING GROUPS

-- Constants
most     = "+"
least    = "-"
any      = "*"
optional = "?"

-- Saves
saved = {}
save  = (any)  -> saved[any.name] = any if any
get   = (name) -> saved[name] and (saved[name].tree and saved[name].tree or saved[name].value) or false
whole = (name) -> saved[name] or false

-- wrap, unwrap
wrap    = (any) -> (value) -> if any.tree then any.tree = value else any.value = value
unwrap  = (any) ->            (any.tree and any.tree or any.value) if any

-- atomic
atomic = {
  name:    (name) => @name = name
  join:    (atom) => switch atom.type
    when "literal", "normal" then @value ..= atom.value
    when "set" then @value = commons.join_sets @value, atom.value
  negate:  => @value = commons.negate_set @value
  repeat:  (operator) => switch type operator
    when "number" then
      if     operator > 0 then @value   = @value\rep math.abs operator
      elseif operator < 0 then
        prevalue = @value
        @value   = @value\rep math.abs operator
        if @type == "set" then @value ..= commons.negate_set prevalue
        else @value ..= commons.negate_pattern prevalue
      else error "Operator can't be 0"
    when "string" then @value ..= operator
}
atomic.__index = atomic
atomic.__call  = atomic.name
atomic.__add   = atomic.join
atomic.__unm   = atomic.negate
atomic.__div   = atomic.repeat

-- Atoms
-- literal "string"
literal = (string) ->
  setmetatable {
    name:  "?"
    type:  "literal"
    value: commons.sanitize string
  }, atomic
-- normal "string"
normal = (string) ->
  setmetatable {
    name:  "?"
    type:  "normal"
    value: string
  }, atomic
-- set "string"
set = (string) ->
  setmetatable {
    name:  "?"
    type:  "set"
    value: string
  }, atomic

-- atomic.combine, atomic.copy
atomic.combine = (atom) => switch atom.type
  when "set" then set commons.join_sets @value, atom.value
  else normal (@value .. atom.value)
atomic.copy    = => switch @type
  when "literal" then literal @value
  when "normal"  then normal  @value
  when "set"     then set     @value

atomic.__concat = atomic.combine

-- elemental
elemental = {
  name:      (name)    =>         @name = name
  join:      (element) =>         @tree = commons.add @tree element.tree
  select:    (index)   =>         @tree[index]
  apply:     (fn)      =>         @tree = [fn atom for i, atom in *@tree]
  transform: (index)   => (fn) -> @tree[index].value = fn @tree[index].value -- (e\transform 5), (a) -> a+1 
}
elemental.__index = elemental
elemental.__call  = elemental.name
elemental.__add   = elemental.join
elemental.__mul   = elemental.apply

-- element
element = (...) ->
  setmetatable {
    name:    "?"
    type:    "element"
    tree:    [atom for i, atom in *{...}]
    factors: {
      separator: ""
      start:     ""
      end:       ""
    }
    _:    elemental
  }, elemental

-- elemental.combine
elemental.combine = (e) =>
  if e
    ex      = element literal ""
    ex.tree = commons.merge @tree, e.tree
    return ex
  return false

elemental.__concat = elemental.combine

-- atomic.toElement
atomic.toElement = =>
  ex      = element @
  ex.name = @name
  ex

atomic.__len = atomic.toElement

-- groupal
groupal = {
  name:    (name)  => @name = name
  join:    (group) => @value ..= group.value
  --
  test:    (string)        => string\match @value
  match:   (string)        => [match for match in string\gmatch @value]
  find:    (string)        => [pair  for pair  in groupal.gfind @value, string]
  replace: (string, rwith) => string\gsub @value, rwith
  count:   (string)        => select 2, @value\gsub string, ""
  atomize:                 => commons.atomize @value
  --
  gmatch: => (string) ->
    matchl = [match for match in string\gmatch @value]
    ix     = 0
    ->
      ix += 1
      return matchl[ix]
}
groupal.__index = groupal
groupal.__call  = groupal.name   -- g "name"
groupal.__add   = groupal.join   -- g + g
groupal.__mod   = groupal.test   -- if g % "str"
groupal.__lt    = groupal.match  -- ml = g < "str"
groupal.__le    = groupal.find   -- fl = g <= "str"
groupal.__pow   = groupal.count  -- c  = g ^ "str"
groupal.__len   = groupal.gmatch -- for match in #g
--
groupal.__div  = (operand) =>
  switch type operand
    when "string"
      if not @_repl_str then @_repl_str = operand
      else   @_repl_pat = operand
      @
    when "function"
      @_repl_fn = operand
      @
    when "number"
      if not @_repl_str then error "No string passed to g /str/?/n"
      @_repl_str\gsub @value, @_repl_fn or @_repl_pat, operand
    when "boolean"
      if not @_repl_str then error "No string passed to g /str/?/bool"
      if operand then @_repl_str\gsub @value, @_repl_fn or @_repl_pat

-- group
group = (element) ->
  prepare = (value) -> (element.factors.start .. value .. element.factors.end .. element.factors.separator)
  return setmetatable {
    name:  "?"
    type:  "group"
    value: do
      _value = ""
      for i, atom in *element.tree
        switch atom.type
          when "literal" then _value ..= prepare commons.sanitize atom.value
          when "normal"  then _value ..= prepare atom.value
          when "set"     then _value ..= prepare atom.value
      if element.factors.separator\len! > 0 then _value = _value\sub 1, -(element.factors.separator\len!)
      _value
  }, groupal

-- compile
elemental.compile = => group @
atomic.compile    = => group element @

-- Module
{
  :debug
  :saved, :save, :get, :whole
  :wrap, :unwrap
  :most, :least, :any, :optional
  atom:
    -- Atomic functions
    name:      atomic.name
    join:      atomic.join
    negate:    atomic.negate
    repeat:    atomic.repeat
    combine:   atomic.combine
    copy:      atomic.copy
    toElement: atomic.toElement
    compile:   atomic.compile
    -- Atoms
    :literal, :normal, :set
  element:
    -- Elemental functions
    name:      elemental.name
    join:      elemental.join
    select:    elemental.select
    apply:     elemental.apply
    transform: elemental.transform
    compile:   elemental.compile
    -- Element
    :element
  group:
    -- Groupal functions
    name:    groupal.name
    join:    groupal.join
    test:    groupal.test
    match:   groupal.match
    replace: groupal.name
    count:   groupal.count
    atomize: groupal.atomize
    gmatch:  groupal.gmatch
    -- Group
    :group
}
