-- lbuilder2 | parsec-rw module
-- By daelvn
commons = require "lbuilder.commons"
import atom    from require "lbuilder.builder"
import atomize from commons

local wrap

-- is_table, is_string
is_table  = (x) -> (type x) == "table"
is_string = (x) -> (type x) == "string"

-- fail, cofail
fail   = (ex, unex)         -> { expecting: ex, unexpected: tostring unex }
cofail = (parser, ex, unex) ->
  if is_string parser.error then { expecting: parser.error, unexpected: tostring unex}
  else fail ex, unex

-- bind
-- thanks cucumber
bind = (...) ->
  functions, amount = {...}, select '#', ...

  (...) -> unpack with t = {...}
    for i = amount, 1, -1 do t = {functions[i] unpack t}

-- and <&>, or <|>, one b<~>
and_ = (pa, pb) -> wrap (input) ->
  ptr = input.pointer
  --
  ra  = pa input
  if is_table ra
    input.pointer = ptr
    ra
  rb = pb input
  if is_table rb
    input.pointer = ptr
    rb
  --
  cofail rb, rb.expected, rb.unexpected

or_ = (pa, pb) -> wrap (input) ->
  ptr = input.pointer
  --
  ra = pa input
  if is_string ra then return ra
  rb = pb input
  if is_string rb then return rb
  --
  input.pointer = ptr
  cofail rb, rb.expected, rb.unexpected

xor_ = (pa, pb) -> wrap (input) ->
  ptr = input.pointer
  --
  ra = pa input
  rb = rb input
  if     (is_table ra)  and (is_table rb)
    input.pointer = ptr
    cofail ra, ra.expected, ra.unexpected
  elseif (is_string ra) and (is_table rb)  then ra
  elseif (is_table ra)  and (is_string rb) then rb
  elseif (is_string ra) and (is_string rb)
    input.pointer = ptr
    cofail rb, rb.expected, rb.unexpected
  else
    input.pointer = ptr
    cofail rb, rb.expected, rb.unexpected

-- forl <, forr >
forl = (pa, pb) -> wrap (input) ->
  ra, _ = and_ pa, pb
  ra if ra
forr = (pa, pb) -> wrap (input) ->
  _, rb = and_ pa, pb
  rb if rb

-- try
try = (parser) -> (input) ->
  ptr  = input.pointer
  --
  read = parser input
  switch type read
    when "table"
      input.pointer = ptr
      cofail parser, read.expected, read.unexpected
    when "string" then read

-- wrap
wrap = (parser) -> setmetatable {
  :parser,

  vbinding: ->
  error: 0

  hbind:  (pa, fn) -> pa.parser   = bind pa.parser, fn
  hibind: (pa, fn) -> pa.parser   = bind fn, pa.parser
  vbind:  (pa, fn) -> pa.vbinding = fn
}, {
  __call: parser
  __shr:  (fn) => @hbind  @, fn
  __shl:  (fn) => @hibind @, fn
  __idiv: (fn) => @vbind  @, fn
  __band: and_
  __bor:  or_
  __bxor: xor_
  __bnot: try
  __lt:  (px, py) ->
    if     @ == px then forl px, py
    elseif @ == py then forr py, px
  __mul: (err) => @error = err
}

-- Radicals
radical = (condition) -> (builder) -> wrap (input) ->
  if read = input\read! then if condition read, builder
    input\consume!
  else fail builder, read

radical_many = (process) -> (condition) -> (builder) -> wrap (input) ->
  parts    = process builder if is_string builder else builder
  radicals = [radical condition part for part in *parts]
  --
  result   = ""
  ni       = (i) -> #radicals - i
  for i=#radicals, 0, -1
    res = radicals[ni i] input
    switch type res
      when "string" then result ..= res
      when "table"  then cofail radicals[ni i], res.expected, res.unexpected
  --
  result


-- Base radicals
_chars    = (s) -> [char for char in s\gmatch "."]
--
char      = (char_)    -> wrap (input) -> radical                ((r,b) -> r == b)    char_    input
charclass = (cclass)   -> wrap (input) -> radical                ((r,b) -> r\match b) cclass   input
string    = (string_)  -> wrap (input) -> radical_many (_chars)  ((r,b) -> r == b)    string_  input
pattern   = (pattern_) -> wrap (input) -> radical_many (atomize) ((r,b) -> r\match b) pattern_ input

-- parser Derivate
parser = (any) -> wrap (input) ->
  switch any.type
    when "literal"       then any.value\len!           > 1 and string any.value or char any.value
    when "normal", "set" then #(atomize any.value)     > 1 and pattern any.value or charclass any.value
    when "element"       then #(any\compile!\atomize!) > 1 and pattern any\compile!\atomize!
    when "group"         then #(any\atomize!)          > 1 and pattern any\atomize!

-- Class derivates
any_char    = wrap (input) -> (charclass ".")  input
letter      = wrap (input) -> (charclass "%a") input
lower       = wrap (input) -> (charclass "%l") input
upper       = wrap (input) -> (charclass "%u") input
digit       = wrap (input) -> (charclass "%d") input
alphanum    = wrap (input) -> (charclass "%w") input
space       = wrap (input) -> (charclass "%s") input
control     = wrap (input) -> (charclass "%c") input
punctuation = wrap (input) -> (charclass "%p") input

letters = letter
digits  = digit
spaces  = space
chars   = any_char

negate = (derivate) -> switch derivate
  when any_char    then wrap (input) -> (charclass "[^.]") input
  when letter      then wrap (input) -> (charclass "%A")   input
  when lower       then wrap (input) -> (charclass "%L")   input
  when upper       then wrap (input) -> (charclass "%U")   input
  when digit       then wrap (input) -> (charclass "%D")   input
  when alphanum    then wrap (input) -> (charclass "%W")   input
  when space       then wrap (input) -> (charclass "%S")   input
  when control     then wrap (input) -> (charclass "%C")   input
  when punctuation then wrap (input) -> (charclass "%P")   input

one_of  = (set) -> (input) -> charclass (parser atom.set set)    input
none_of = (set) -> (input) -> charclass (parser -(atom.set set)) input

-- many, any
_any = (choose) -> (parser_, till) -> wrap (input) ->
  result = {}
  read   = parser_ input
  return (choose (cofail parser_, read.expected, read.unexpected), "") if is_table read
  --
  while is_string read
    table.insert result, read
    read = parser_ input
  --
  if till
    readTill = till input
    switch type readTill
      when "table"  then cofail till, readTill.expected, readTill.unexpected
      when "string" then result
  --
  result

any  = _any (r, s) -> s
many = _any (r, s) -> r

-- count
count = (number) -> (parser_) -> wrap (input) ->
  result = {}
  for i=1, number
    read = parser_ input
    switch type read
      when "table"  then cofail parser_, read.expected, read.unexpected
      when "string" then table.insert result, read
  result

-- till, choice, one
till   = (parser_) -> parser_
choice = or_
one    = xor_

-- do
do_ = (statl) -> bind (unpack statl)

-- Module
{
  :is_table, :is_string, :bind, :wrap,
  :char, :charclass, :string, :pattern, :parser,
  :negate, :one_of, :none_of, :any, :many, :count,
  :till ,:choice ,:one ,:do_ ,:try,
  fail:
    :fail, :cofail
  logic:
    :and_, :or_, :xor_,
    :forl, :forr
  radical:
    :radical, :radical_many
  classes:
    :any_char, :letter, :lower, :upper, :digit, :alphanum, :space, :control, :punctuation,
    :chars, :letters, :digits, :spaces
}
