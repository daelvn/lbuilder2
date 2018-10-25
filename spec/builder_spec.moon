-- lbuilder2 | builder.moon tests
builder = require "lbuilder.builder"
import wrap, unwrap from builder
import most, least, any, optional from builder

-- Atoms
describe "atoms", ->
  import atom                 from builder
  import literal, normal, set from atom
  describe "literals", ->
    randomize false
    --
    local la, lb, lc
    it "should define a literal", ->
      la = literal "a[x]%n(o).."
      --
      assert.are.equals "a%[x%]%%n%(o%)%.%.", (unwrap la)
      assert.are.equals "literal",            la.type
    it "should name a literal", ->
      la "Name"
      --
      assert.are.equals "Name", la.name
    it "should join two literals", ->
      lb = literal "pl"
      --
      la + lb
      --
      assert.are.equals "a%[x%]%%n%(o%)%.%.pl", (unwrap la)
    it "should match at least n literals", ->
      lc = literal "pl"
      --
      lc/5
      --
      assert.are.equals "plplplplpl", (unwrap lc)
    it "should match at most n literals", ->
      lc = literal "pl"
      --
      lc/-5
      --
      assert.are.equals "plplplplpl[^p][^l]", (unwrap lc)
    it "should modify the literal", ->
      lc = literal "pl"
      --
      lc/most
      --
      assert.are.equals "pl+", (unwrap lc)
    it "should combine two literals", ->
      lb = literal "ok"
      lc = literal "pl"
      --
      ld = lb .. lc
      --
      assert.are.equals "okpl",   (unwrap ld)
      assert.are.equals "normal", ld.type
    it "should copy a literal", ->
      lc = literal "pl"
      --
      ld = lc\copy!
      --
      assert.are.same lc, ld
    it "should convert to an element", ->
      lc = literal "pl"
      --
      ec = #lc
      --
      assert.are.equals "pl",      (unwrap ec.tree[1])
      assert.are.equals "element", ec.type
  describe "normals", ->
    randomize false
    --
    local na, nb, nc
    it "should define a normal", ->
      na = normal "a[x]%n(o).."
      --
      assert.are.equals "a[x]%n(o)..", (unwrap na)
      assert.are.equals "normal", na.type
    it "should name a normal", ->
      na "Name"
      --
      assert.are.equals "Name", na.name
    it "should join two normals", ->
      nb = normal "pl"
      --
      na + nb
      --
      assert.are.equals "a[x]%n(o)..pl", (unwrap na)
    it "should match at least n normals", ->
      nc = normal "pl"
      --
      nc/5
      --
      assert.are.equals "plplplplpl", (unwrap nc)
    it "should match at most n normals", ->
      nc = normal "pl"
      --
      nc/-5
      --
      assert.are.equals "plplplplpl[^p][^l]", (unwrap nc)
    it "should modify the normal", ->
      nc = normal "pl"
      --
      nc/most
      --
      assert.are.equals "pl+", (unwrap nc)
    it "should combine two normals", ->
      nb = normal "ok"
      nc = normal "pl"
      --
      nd = nb .. nc
      --
      assert.are.equals "okpl",   (unwrap nd)
      assert.are.equals "normal", nd.type
    it "should copy a normal", ->
      nc = normal "pl"
      --
      nd = nc\copy!
      --
      assert.are.same nc, nd
    it "should convert to an element", ->
      nc = normal "pl"
      --
      ec = #nc
      --
      assert.are.equals "pl",      (unwrap ec.tree[1])
      assert.are.equals "element", ec.type
  describe "sets", ->
    randomize false
    --
    local sa, sb, sc
    it "should define a set", ->
      sa = set "[abc%d]"
      --
      assert.are.equals "[abc%d]", (unwrap sa)
      assert.are.equals "set",     sa.type
    it "should name a set", ->
      sa "Name"
      --
      assert.are.equals sa.name, "Name"
    it "should join two sets", ->
      sb = set "[efg]"
      --
      sa + sb
      --
      assert.are.equals "[abc%defg]", (unwrap sa)
    it "should match at least n sets", ->
      sc = set "[ab]"
      --
      sc/3
      --
      assert.are.equals "[ab][ab][ab]", (unwrap sc)
    it "should match at most n sets", ->
      sc = set "[ab]"
      --
      sc/-3
      --
      assert.are.equals "[ab][ab][ab][^ab]", (unwrap sc)
    it "should modify the set", ->
      sc = set "[ab]"
      --
      sc/least
      --
      assert.are.equals "[ab]-", (unwrap sc)
    it "should combine two sets", ->
      sb = set "[ab]"
      sc = set "[cd]"
      --
      sd = sb .. sc
      --
      assert.are.equals "[abcd]", (unwrap sd)
      assert.are.equals "set",    sd.type
    it "should negate a set", ->
      sc = set "[ab]"
      --
      -sc
      --
      assert.are.equal "[^ab]", (unwrap sc)
    it "should copy a set", ->
      sc = set "[ab]"
      --
      sd = sc\copy!
      --
      assert.are.same sc, sd
    it "should convert to an element", ->
      sc = set "[ab]"
      --
      ec = #sc
      --
      assert.are.equals "[ab]",    (unwrap ec.tree[1])
      assert.are.equals "element", ec.type

describe "elements", ->
  import element from builder.element
  local ea, eb
  it "should define an element", ->
    la = builder.atom.literal "abc"
    na = builder.atom.normal  "%ab"
    sa = builder.atom.set     "[ab]"
    --
    ea = element la, na, sa
    --
    assert.are.equals "abc",     (unwrap ea.tree[1])
    assert.are.equals "%ab",     (unwrap ea.tree[2])
    assert.are.equals "[ab]",    (unwrap ea.tree[3])
    assert.are.equals "element", ea.type
  it "should name an element", ->
    ea "Name"
    --
    assert.are.equals "Name", ea.name
  it "should select an atom", ->
    e2 = ea\select 2
    --
    assert.are.equals ea.tree[2], e2
  it "should apply a function", ->
    fn = (atom) ->
      atom.value ..= "+"
      atom
    ea * fn
    --
    assert.are.equals "abc+",  (unwrap ea\select 1)
    assert.are.equals "%ab+",  (unwrap ea\select 2)
    assert.are.equals "[ab]+", (unwrap ea\select 3)
  it "should transform an element", ->
    (ea\transform 5), (a) -> a .. "+"
    --
    assert.are.equals "abc++",  (unwrap ea\select 1)
    assert.are.equals "%ab++",  (unwrap ea\select 2)
    assert.are.equals "[ab]++", (unwrap ea\select 3)
  it "should join two elements", ->
    ea = element la, na, sa
    eb = element sa, na, la
    --
    ea + eb
    --
    assert.are.equal "abc", (unwrap ea\select 1)
    assert.are.equal "abc", (unwrap ea\select 6)
  it "should combine two elements", ->
    ea = element la, na, sa
    --
    ec = ea .. eb
    --
    assert.are.equal "abc", (unwrap ec\select 1)
    assert.are.equal "abc", (unwrap ec\select 6)
  it "should compile into a group", ->
    eb.factors.separator = "/"
    eb.factors.start     = "<"
    eb.factors.end       = ">"
    --
    gb = eb\compile!
    --
    assert.are.equal "</[ab]/%ab/abc/>", (unwrap gb)

describe "groups", ->
  import literal, normal, set from builder.atom
  local ga, gb
  it "should define a group", ->
    ga = (literal "a")\compile!
    --
    assert.are.equal "a",     (unwrap ga)
    assert.are.equal "group", ga.type
  it "should name a group", ->
    ga "Name"
    --
    assert.are.equal "Name", ga.name
  it "should join two groups", ->
    gb = (literal "b")\compile!
    --
    ga + gb
    --
    assert.are.equal "ab", (unwrap ga)
  it "should test a group", ->
    stra = "ab"
    strb = "ac"
    --
    assert.is.truthy (ga % stra)
    assert.is.falsy  (ga % strb)
  it "should match a group", ->
    stra = "ab"
    strb = "ac"
    --
    mla = ga < stra
    mlb = ga < strb
    --
    assert.are.equal "ab", mla[1]
    assert.is.falsy  mlb
  it "should find a group", ->
    stra = "xabx"
    strb = "xacx"
    --
    fla = ga <= stra
    flb = ga <= strb
    --
    assert.are.equal 2, (select 1, fla)
    assert.are.equal 3, (select 2, fla)
    assert.is.falsy flb
  it "should count a group", ->
    stra = "xabxabxabx"
    --
    assert.are.equal 3, (ga ^ stra)
  it "should iterate over the group's matches", ->
    gc   = (normal "a.")\compile!
    stra = "abacadaea-f"
    --
    for match in (#gc) stra
      assert.is.truthy match\match "a."
  it "should iterate over the group's finds", ->
    gc   = (normal "a.")\compile!
    stra = "abacadaea-f"
    --
    for fst, fix in (-gc) stra
      assert.are.truthy fst, fix
  describe "replacements", ->
    it "should replace the group", ->
      ge  = (literal "o")\compile!
      str = "hello"
      --
      strr = ge /str/"a"/true
      --
      assert.are.equal "hella", strr
    it "should replace the group with a function", ->
      ge  = (normal "%b{}")\compile!
      print ge.value
      str = "this is {just} a string"
      --
      strr = ge /str/((x) -> "*"..x.."*")/true
      --
      assert.are.equal "this is *{just}* a string", strr
    it "should replace the group with a limit", ->
      ge  = (normal "a.")\compile!
      str = "ax_az_ay"
      --
      strr = ge /str/"nn"/2
      --
      assert.are.equal "nn_nn_ay", strr

describe "saves", ->
  import saved, save, get, element from builder
  import literal                   from builder.atom
  la = (literal "ab") "Ab"
  it "should save an element", ->
    save la
    --
    assert.are.equal saved.Ab, la
  it "should get a saved element", ->
    lx = element "Ab"
    --
    assert.are.equal la, lx
  it "should obtain the value of a saved element", ->
    lx = get "Ab"
    assert.are.equal "ab", lx
