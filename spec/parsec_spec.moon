-- lbuilder2 | parsec.moon tests
builder = require "lbuilder.builder"
parsec  = require "lbuilder.parsec"

-- Miscelaneous functions
describe "misc", ->
  it "identify a table #is_table", -> pending "todo"
  it "identify a string #is_string", -> pending "todo"

-- Fails
describe "fails", ->
  it "fails #fail", -> pending "todo"
  it "complex fails #cofail", -> pending "todo"

-- Radicals
describe "radicals", ->
  it "creates a radical #radical", -> pending "todo"
  it "creates a plural radical #radical_many", -> pending "todo"

  it "creates a char radical #char", -> pending "todo"
  it "creates a charclass radical #charclass", -> pending "todo"
  it "creates a string radical #string", -> pending "todo"
  it "creates a pattern radical #pattern", -> pending "todo"

-- Derivates
describe "derivates", ->
  it "creates a new parser #parser", -> pending "todo"

  it "creates an any_char class derivate #any_char", -> pending "todo"
  it "creates a letter class derivate #letter", -> pending "todo"
  it "creates an upper class derivate #upper", -> pending "todo"
  it "creates a digit class derivate #digit", -> pending "todo"
  it "creates an alphanumeric class derivate #alphanum", -> pending "todo"
  it "creates a space class derivate #space", -> pending "todo"
  it "creates a control class derivate #control", -> pending "todo"
  it "creates a punctuation class derivate #punctuation", -> pending "todo"
  it "negates class derivates #negate", -> pending "todo"

-- Selectors
describe "selectors", ->
  it "matches one of many characters #one_of", -> pending "todo"
  it "matches none of many characters #none_of", -> pending "todo"

-- Modifiers
describe "modifiers", ->
  it "matches many parsers if any #any", -> pending "todo"
  it "matches many parsers #many", -> pending "todo"

  it "matches a parser a certain amount of times #count", -> pending "todo"

  it "matches many parsers till a parser if any #any_till", -> pending "todo"
  it "matches many parsers till a parser #many_till", -> pending "todo"

-- Logic
describe "logic", ->
  it "Matches both parsers #and", -> pending "todo"
  it "Matches any parser #or #choice", -> pending "todo"
  it "Matches either parser #xor #one", -> pending "todo"
  it "Matches the left parser #forl", -> pending "todo"
  it "Matches the right parser #forr", -> pending "todo"

-- Do, Try, Bind
describe "try", ->
  it "tries a parser #try", -> pending "todo"
describe "do", ->
  it "combines several parsers #do", -> pending "todo"
describe "bind", ->
  it "combines two parsers #bind", -> pending "todo"
