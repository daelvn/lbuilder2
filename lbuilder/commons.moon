-- lbuilder2 | Commons
-- String indexing
(getmetatable '').__index = (i) =>
  if (type i) == "number"
    string.sub @, i
  else
    string[i]

-- Sanitize
sanitize = (pattern) -> pattern\gsub "[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%0"
-- Atomize
atomize = (pattern) ->
  pattern = pattern\gsub "[()]", ""
  atom  = ""
  atoms = {}
  open  = 0
  i     = 0
  mark  = false
  for c in pattern\gmatch "."
    switch c
      when "[" then open = 1
      when "]" then open = 0
      when "%" then open = 3
      when "b" then open = 4 if open == 3
    --
    if     open == 3 and i == 1 then open = 0
    elseif open == 4 and i == 3 then open = 0
    --
    switch c
      when "+", "-", "*", "?"
        atoms[#atoms] ..= c
      else atom ..= c
    --
    if open != 0
      i += 1
      continue
    else
      mark = true
      i = 0
    --
    if mark
      table.insert atoms, atom
      atom = ""
      mark = false
  --
  atoms = [atom for atom in *atoms when atom != ""]
  atoms
-- Negate pattern
negate_pattern = (pattern) ->
  result = ""
  for c in pattern\gmatch "."
    result ..= "[^" .. c .. "]"
  result
-- Copy table
copy  = (obj, seen) ->
  if (type obj) != "table" then return obj
  if seen and seen[obj] then return seen[obj]
  s      = seen or {}
  res    = setmetatable {}, getmetatable obj
  s[obj] = res
  for k, v in pairs obj do res[copy k, s] = copy v, s
  res
-- Merge two tables
merge = (table1, table2) ->
  for k,v in pairs table2
    if ((type v) == "table") and ((type (table1[k] or false)) == "table")
      merge table1[k] table2[k]
    else table1[k] = v
  table1
-- Add two tables together
add = (table1, table2) ->
  for i,v in *table2
    table.insert table1, v
-- Set operations
join_sets  = (set1, set2) -> "[" .. (set1\sub 2, -2) .. (set2\sub 2, -2) .. "]"
negate_set = (set) ->
  if     set\match "^%[^" then "["  .. set\sub 3
  elseif set\match "%]$"  then "[^" .. set\sub 2
  else                         "[^" .. set .. "]"
  
-- Export
{ :sanitize, :atomize, :negate_pattern, :copy, :merge, :add, :join_sets, :negate_set }
