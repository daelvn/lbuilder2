-- lbuilder | 30.10.2018
-- By daelvn
-- Utils for builder.moon

{
  is_atom:    (x) -> (x.type == "generic") or (x.type == "literal") or (x.type == "normal") or (x.type == "set")
  is_generic: (x) -> x.type == "generic"
  is_literal: (x) -> x.type == "literal"
  is_normal:  (x) -> x.type == "normal"
  is_set:     (x) -> x.type == "set"
  is_element: (x) -> x.type == "element"
  is_group:   (x) -> x.type == "group"
}
