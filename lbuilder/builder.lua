local commons = require("lbuilder.commons")
local write, debuggable, debug_all
do
  local _obj_0 = commons.stderr
  write, debuggable, debug_all = _obj_0.write, _obj_0.debuggable, _obj_0.debug_all
end
local debug
debug = function(b)
  return commons.stderr.debug(b)
end
local most = "+"
local least = "-"
local any = "*"
local optional = "?"
local saved = { }
local save
save = function(any)
  if any then
    saved[any.name] = any
  end
end
local get
get = function(name)
  return saved[name] and (saved[name].tree and saved[name].tree or saved[name].value) or false
end
local whole
whole = function(name)
  return saved[name] or false
end
local wrap
wrap = function(any)
  return function(value)
    if any.tree then
      any.tree = value
    else
      any.value = value
    end
  end
end
local unwrap
unwrap = function(any)
  if any then
    return (any.tree and any.tree or any.value)
  end
end
local atomic = {
  name = function(self, name)
    self.name = name
  end,
  join = function(self, atom)
    local _exp_0 = atom.type
    if "literal" == _exp_0 or "normal" == _exp_0 then
      self.value = self.value .. atom.value
    elseif "set" == _exp_0 then
      self.value = commons.join_sets(self.value, atom.value)
    end
  end,
  negate = function(self)
    self.value = commons.negate_set(self.value)
  end,
  ["repeat"] = function(self, operator)
    local _exp_0 = type(operator)
    if "number" == _exp_0 then
      if operator > 0 then
        self.value = self.value:rep(math.abs(operator))
      elseif operator < 0 then
        local prevalue = self.value
        self.value = self.value:rep(math.abs(operator))
        if self.type == "set" then
          self.value = self.value .. commons.negate_set(prevalue)
        else
          self.value = self.value .. commons.negate_pattern(prevalue)
        end
      else
        return error("Operator can't be 0")
      end
    elseif "string" == _exp_0 then
      self.value = self.value .. operator
    end
  end
}
atomic.__index = atomic
atomic.__call = atomic.name
atomic.__add = atomic.join
atomic.__unm = atomic.negate
atomic.__div = atomic["repeat"]
local literal
literal = function(string)
  return setmetatable({
    name = "?",
    type = "literal",
    value = commons.sanitize(string)
  }, atomic)
end
local normal
normal = function(string)
  return setmetatable({
    name = "?",
    type = "normal",
    value = string
  }, atomic)
end
local set
set = function(string)
  return setmetatable({
    name = "?",
    type = "set",
    value = string
  }, atomic)
end
atomic.combine = function(self, atom)
  local _exp_0 = atom.type
  if "set" == _exp_0 then
    return set(commons.join_sets(self.value, atom.value))
  else
    return normal((self.value .. atom.value))
  end
end
atomic.copy = function(self)
  local _exp_0 = self.type
  if "literal" == _exp_0 then
    return literal(self.value)
  elseif "normal" == _exp_0 then
    return normal(self.value)
  elseif "set" == _exp_0 then
    return set(self.value)
  end
end
atomic.__concat = atomic.combine
local elemental = {
  name = function(self, name)
    self.name = name
  end,
  join = function(self, element)
    self.tree = commons.add(self:tree(element.tree))
  end,
  select = function(self, index)
    return self.tree[index]
  end,
  apply = function(self, fn)
    do
      local _accum_0 = { }
      local _len_0 = 1
      local _list_0 = self.tree
      for _index_0 = 1, #_list_0 do
        local i, atom = _list_0[_index_0]
        _accum_0[_len_0] = fn(atom)
        _len_0 = _len_0 + 1
      end
      self.tree = _accum_0
    end
  end,
  transform = function(self, index)
    return function(fn)
      self.tree[index].value = fn(self.tree[index].value)
    end
  end
}
elemental.__index = elemental
elemental.__call = elemental.name
elemental.__add = elemental.join
elemental.__mul = elemental.apply
local element
element = function(...)
  return setmetatable({
    name = "?",
    type = "element",
    tree = (function(...)
      local _accum_0 = { }
      local _len_0 = 1
      local _list_0 = {
        ...
      }
      for _index_0 = 1, #_list_0 do
        local i, atom = _list_0[_index_0]
        _accum_0[_len_0] = atom
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)(...),
    factors = {
      separator = "",
      start = "",
      ["end"] = ""
    },
    _ = elemental
  }, elemental)
end
elemental.combine = function(self, e)
  if e then
    local ex = element(literal(""))
    ex.tree = commons.merge(self.tree, e.tree)
    return ex
  end
  return false
end
elemental.__concat = elemental.combine
atomic.toElement = function(self)
  local ex = element(self)
  ex.name = self.name
  return ex
end
atomic.__len = atomic.toElement
local groupal = {
  name = function(self, name)
    self.name = name
  end,
  join = function(self, group)
    self.value = self.value .. group.value
  end,
  test = function(self, string)
    return string:match(self.value)
  end,
  match = function(self, string)
    local _accum_0 = { }
    local _len_0 = 1
    for match in string:gmatch(self.value) do
      _accum_0[_len_0] = match
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end,
  find = function(self, string)
    local _accum_0 = { }
    local _len_0 = 1
    for pair in groupal.gfind(self.value, string) do
      _accum_0[_len_0] = pair
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end,
  replace = function(self, string, rwith)
    return string:gsub(self.value, rwith)
  end,
  count = function(self, string)
    return select(2, self.value:gsub(string, ""))
  end,
  atomize = function(self)
    return commons.atomize(self.value)
  end,
  gmatch = function(self)
    return function(string)
      local matchl
      do
        local _accum_0 = { }
        local _len_0 = 1
        for match in string:gmatch(self.value) do
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
    end
  end
}
groupal.__index = groupal
groupal.__call = groupal.name
groupal.__add = groupal.join
groupal.__mod = groupal.test
groupal.__lt = groupal.match
groupal.__le = groupal.find
groupal.__pow = groupal.count
groupal.__len = groupal.gmatch
groupal.__div = function(self, operand)
  local _exp_0 = type(operand)
  if "string" == _exp_0 then
    if not self._repl_str then
      self._repl_str = operand
    else
      self._repl_pat = operand
    end
    return self
  elseif "function" == _exp_0 then
    self._repl_fn = operand
    return self
  elseif "number" == _exp_0 then
    if not self._repl_str then
      error("No string passed to g /str/?/n")
    end
    return self._repl_str:gsub(self.value, self._repl_fn or self._repl_pat, operand)
  elseif "boolean" == _exp_0 then
    if not self._repl_str then
      error("No string passed to g /str/?/bool")
    end
    if operand then
      return self._repl_str:gsub(self.value, self._repl_fn or self._repl_pat)
    end
  end
end
local group
group = function(element)
  local prepare
  prepare = function(value)
    return (element.factors.start .. value .. element.factors["end"] .. element.factors.separator)
  end
  return setmetatable({
    name = "?",
    type = "group",
    value = (function()
      local _value = ""
      local _list_0 = element.tree
      for _index_0 = 1, #_list_0 do
        local i, atom = _list_0[_index_0]
        local _exp_0 = atom.type
        if "literal" == _exp_0 then
          _value = _value .. prepare(commons.sanitize(atom.value))
        elseif "normal" == _exp_0 then
          _value = _value .. prepare(atom.value)
        elseif "set" == _exp_0 then
          _value = _value .. prepare(atom.value)
        end
      end
      if element.factors.separator:len() > 0 then
        _value = _value:sub(1, -(element.factors.separator:len()))
      end
      return _value
    end)()
  }, groupal)
end
elemental.compile = function(self)
  return group(self)
end
atomic.compile = function(self)
  return group(element(self))
end
return debug_all({
  debug = debug,
  saved = saved,
  save = save,
  get = get,
  whole = whole,
  wrap = wrap,
  unwrap = unwrap,
  most = most,
  least = least,
  any = any,
  optional = optional,
  atom = debug_all({
    name = atomic.name,
    join = atomic.join,
    negate = atomic.negate,
    ["repeat"] = atomic["repeat"],
    combine = atomic.combine,
    copy = atomic.copy,
    toElement = atomic.toElement,
    compile = atomic.compile,
    literal = literal,
    normal = normal,
    set = set
  }),
  element = debug_all({
    name = elemental.name,
    join = elemental.join,
    select = elemental.select,
    apply = elemental.apply,
    transform = elemental.transform,
    compile = elemental.compile,
    element = element
  }),
  group = debug_all({
    name = groupal.name,
    join = groupal.join,
    test = groupal.test,
    match = groupal.match,
    replace = groupal.name,
    count = groupal.count,
    atomize = groupal.atomize,
    gmatch = groupal.gmatch,
    group = group
  })
})
