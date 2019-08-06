local commons = require("lbuilder.commons")
local utils = require("lbuilder.utils")
local inspect = require("inspect")
local log = require("log")
local is_atom, is_set
is_atom, is_set = utils.is_atom, utils.is_set
local atom = commons.multi({
  ["__call,label"] = function(self, name)
    self.name = name
  end,
  ["__add,join"] = function(self, atom)
    local _exp_0 = atom.type
    if "set" == _exp_0 then
      self.value = commons.join_sets(self.value, atom.value)
    else
      self.value = self.value .. atom.value
    end
    return self
  end,
  ["__unm,negate"] = function(self)
    local _exp_0 = self.type
    if "set" == _exp_0 then
      self.value = commons.negate_set(self.value)
    else
      self.value = commons.negate_pattern(self.value)
    end
    return self
  end,
  ["__div,repeat"] = function(self, oper)
    local _exp_0 = type(oper)
    if "number" == _exp_0 then
      if oper > 0 then
        self.value = self.value:rep(oper)
      elseif oper < 0 then
        local prev = self.value
        self.value = self.value:rep(math.abs(oper))
        local _exp_1 = self.type
        if "set" == _exp_1 then
          self.value = self.value .. commons.negate_set(prev)
        else
          self.value = self.value .. commons.negate_pattern(prev)
        end
      end
    elseif "string" == _exp_0 then
      self.value = self.value .. oper
    end
    return self
  end,
  ["__concat,combine"] = function(self, atom)
    log.warn((self.value .. atom.value))
    log.warn(inspect(self.builder))
    log.warn(inspect(self:for_literal((self.value .. atom.value))))
    if (is_set(self)) and (is_set(atom)) then
      return self:builder(common.join_sets(self.value, atom.value))
    else
      return self:builder((self.value .. atom.value))
    end
  end,
  ["copy"] = function(self)
    return self:builder(self.value, self.name, self.type)
  end,
  ["__mod,set_builder"] = function(self, kind)
    return function(f)
      self["for_" .. tostring(kind)] = f
    end
  end,
  ["__len,to_element"] = function(self)
    if self.for_element then
      return (self:for_element(self)):label(self.name)
    end
  end,
  ["compile"] = function(self)
    if self.for_group and self.for_element then
      return (self:for_group(self:for_element(self))):label(self.name)
    end
  end
})
atom.__index = atom
local element = commons.multi({
  ["__call,label"] = function(self, name)
    self.name = name
  end,
  ["__add,join"] = function(self, element)
    self.tree = commons.merge(self.tree, element.tree)
    return self
  end,
  ["__div,select"] = function(self, index)
    return self.tree[index]
  end,
  ["__mul,apply"] = function(self, f)
    do
      local _accum_0 = { }
      local _len_0 = 1
      local _list_0 = self.tree
      for _index_0 = 1, #_list_0 do
        local i, atom = _list_0[_index_0]
        _accum_0[_len_0] = f(atom)
        _len_0 = _len_0 + 1
      end
      self.tree = _accum_0
    end
    return self
  end,
  ["__mod,transform"] = function(self, index)
    return function(f)
      self.tree[index].value = f(self.tree[index].value)
    end
  end,
  ["set_builder"] = function(self, kind)
    return function(f)
      self["for_" .. tostring(kind)] = f
    end
  end,
  ["compile"] = function(self)
    if self.for_group then
      return (self:for_group(self)):label(self.name)
    end
  end,
  ["__concat,combine"] = function(self, e)
    if e and self.for_literal then
      local ex
      if self.for_literal then
        ex = self:builder(self:for_literal(""))
      end
      ex.tree = commons.merge(self.tree, e.tree)
      return ex
    end
  end
})
element.__index = element
local group = commons.multi({
  ["__call,label"] = function(self, name)
    self.name = name
  end,
  ["__add,join"] = function(self, group)
    self.value = self.value .. group.value
  end,
  ["__mod,test"] = function(self, s)
    return s:match(self.value)
  end,
  ["__lt,match"] = function(self, s)
    local _accum_0 = { }
    local _len_0 = 1
    for match in s:gmatch(self.value) do
      _accum_0[_len_0] = match
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end,
  ["__pow,count"] = function(self, s)
    return select(2, s:gsub(self.value, ""))
  end,
  ["set_builder"] = function(self, kind)
    return function(f)
      self["for_" .. tostring(kind)] = f
    end
  end,
  ["__len,gmatch"] = function(self, s)
    local matchl
    do
      local _accum_0 = { }
      local _len_0 = 1
      for match in s:gmatch(self.value) do
        _accum_0[_len_0] = match
        _len_0 = _len_0 + 1
      end
      matchl = _accum_0
    end
    local ix = 0
    return function()
      ix = ix + 1
      return matchl[ix]
    end
  end,
  ["replace"] = function(self, s, w)
    return s:gsub(self.value, w)
  end,
  ["atomize"] = function(self)
    return commons.atomize(self.value)
  end,
  ["__div"] = function(self, oper)
    local _exp_0 = type(oper)
    if "string" == _exp_0 then
      if not self._rstr then
        self._rstr = oper
      else
        self._rpat = oper
      end
      return self
    elseif "function" == _exp_0 then
      self._rfn = oper
      return self
    elseif "number" == _exp_0 then
      if not self._rstr then
        error("No string passed to g /str/?/n")
      end
      return self._rstr:gsub(self.value, (self._rfn or self._rpat), oper)
    elseif "boolean" == _exp_0 then
      if not self._rstr then
        error("No string passed to g /str/?/bool")
      end
      if oper then
        return (function()
          local _base_0 = self._rstr
          local _fn_0 = _base_0.gsub
          return function(...)
            return _fn_0(_base_0, ...)
          end
        end)(), (self._rfn or self._rpat)
      end
    end
  end
})
group.__index = group
return {
  atom = atom,
  element = element,
  group = group
}
