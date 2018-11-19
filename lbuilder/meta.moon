-- lbuilder | 30.10.2018
-- By daelvn
-- Metatables for builder.moon
commons = require "lbuilder.commons"
utils   = require "lbuilder.utils"
inspect = require "inspect"
log     = require "log"
import
  is_atom
  is_set
  from utils


atom = commons.multi {
  "__call,label":     (name) =>
    @name = name
  "__add,join":       (atom) =>
    switch atom.type
      when "set" then @value   = commons.join_sets @value, atom.value
      else            @value ..= atom.value
    @
  "__unm,negate":           =>
    switch @type
      when "set" then @value   = commons.negate_set     @value
      else            @value   = commons.negate_pattern @value
    @
  "__div,repeat":     (oper) =>
    switch type oper
      when "number"
        if     oper > 0 then @value = @value\rep oper
        elseif oper < 0 then
          prev   = @value
          @value = @value\rep math.abs oper
          switch @type
            when "set" then @value ..= commons.negate_set     prev
            else            @value ..= commons.negate_pattern prev
      when "string"
        @value ..= oper
    @
  "__concat,combine":  (atom) =>
    --log.warn (@value .. atom.value)
    --log.warn inspect @builder
    --log.warn inspect @builder (@value .. atom.value)
    if (is_set @) and (is_set atom) then @builder common.join_sets @value, atom.value
    else                                 @builder (@value .. atom.value)
  "copy":                     =>
    @builder @value, @name, @type
  "__mod,set_builder": (kind) =>
    (f) -> @["for_#{kind}"] = f
  "__len,to_element":         =>
    return (@for_element @)\label @name if @for_element
  "compile":                  =>
    return (@for_group @for_element @)\label @name if @for_group and @for_element
}
atom.__index = atom

element = commons.multi {
  "__call,label":     (name)    =>
    @name = name
  "__add,join":       (element) =>
    @tree = commons.merge @tree, element.tree
    @
  "__div,select":     (index)   =>
    @tree[index]
  "__mul,apply":      (f)       =>
    @tree = [f atom for i, atom in *@tree]
    @
  "__mod,transform":  (index)   =>
    (f) -> @tree[index].value = f @tree[index].value
  "set_builder": (kind)         =>
    (f) -> @["for_#{kind}"] = f
  "compile":                    =>
    return (@for_group @)\label @name if @for_group
  "__concat,combine": (e)       =>
    if e and @for_literal
      ex      = @builder @for_literal "" if @for_literal
      ex.tree = commons.merge @tree, e.tree
      return ex
}
element.__index = element

group = commons.multi {
  "__call,label": (name)  => @name = name
  "__add,join":   (group) => @value ..= group.value
  "__mod,test":   (s)     => s\match @value
  "__lt,match":   (s)     => [match for match in s\gmatch @value]
  "__pow,count":  (s)     => select 2, s\gsub @value, ""
  "set_builder":  (kind)  => (f) -> @["for_#{kind}"] = f
  "__len,gmatch": (s)     =>
    matchl = [match for match in s\gmatch @value]
    ix     = 0
    ->
      ix += 1
      return matchl[ix]
  "replace":      (s, w)  => s\gsub @value, w
  "atomize":              => commons.atomize @value
  "__div":        (oper)  => switch type oper
    when "string"
      if not @_rstr then @_rstr = oper
      else               @_rpat = oper
      @
    when "function"
      @_rfn = oper
      @
    when "number"
      if not @_rstr then error "No string passed to g /str/?/n"
      @_rstr\gsub @value, (@_rfn or @_rpat), oper
    when "boolean"
      if not @_rstr then error "No string passed to g /str/?/bool"
      if oper       then @_rstr\gsub, (@_rfn or @_rpat)
}
group.__index = group

{ :atom, :element, :group }
