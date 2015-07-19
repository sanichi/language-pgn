# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "PGN grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-pgn")

    runs ->
      grammar = atom.grammars.grammarForScopeName("source.pgn")

  it "parses the grammar", ->
    expect(grammar).toBeDefined()
    expect(grammar.scopeName).toBe "source.pgn"

  it "selects the grammar for sample file", ->
    waitsForPromise ->
      atom.workspace.open('sample.pgn')

    runs ->
      expect(atom.workspace.getActiveTextEditor().getGrammar()).toBe grammar

  describe "fragments", ->

    describe "tag pairs", ->

      it "required", ->
        {tokens} = grammar.tokenizeLine('[White "Magnus Carlsen"]')
        expect(tokens[0]).toEqual value: "[", scopes: ["source.pgn"]
        expect(tokens[1]).toEqual value: "White", scopes: ["source.pgn", "keyword.control.pgn"]
        expect(tokens[2]).toEqual value: " ", scopes: ["source.pgn"]
        expect(tokens[3]).toEqual value: '"', scopes: ["source.pgn", "string.quoted.double.pgn", "punctuation.definition.string.begin.pgn"]
        expect(tokens[4]).toEqual value: "Magnus Carlsen", scopes: ["source.pgn", "string.quoted.double.pgn"]
        expect(tokens[5]).toEqual value: '"', scopes: ["source.pgn", "string.quoted.double.pgn", "punctuation.definition.string.end.pgn"]
        expect(tokens[6]).toEqual value: "]", scopes: ["source.pgn"]

      it "optional", ->
        {tokens} = grammar.tokenizeLine('[ECO "A00"]')
        expect(tokens[0]).toEqual value: "[", scopes: ["source.pgn"]
        expect(tokens[1]).toEqual value: "ECO", scopes: ["source.pgn", "keyword.other.special-method.pgn"]
        expect(tokens[2]).toEqual value: " ", scopes: ["source.pgn"]
        expect(tokens[3]).toEqual value: '"', scopes: ["source.pgn", "string.quoted.double.pgn", "punctuation.definition.string.begin.pgn"]
        expect(tokens[4]).toEqual value: "A00", scopes: ["source.pgn", "string.quoted.double.pgn"]
        expect(tokens[5]).toEqual value: '"', scopes: ["source.pgn", "string.quoted.double.pgn", "punctuation.definition.string.end.pgn"]
        expect(tokens[6]).toEqual value: "]", scopes: ["source.pgn"]

    describe "move text", ->

      it "result only", ->
        {tokens} = grammar.tokenizeLine("1-0")
        expect(tokens[0]).toEqual value: "1-0", scopes: ["source.pgn", "markup.bold.pgn", "string.quoted.double.pgn"]

      it "comment and result only", ->
        {tokens} = grammar.tokenizeLine("{Abandoned.} *-*")
        expect(tokens[0]).toEqual value: "{Abandoned.}", scopes: ["source.pgn", "markup.bold.pgn", "comment.block.documentation.pgn"]
        expect(tokens[1]).toEqual value: " ", scopes: ["source.pgn", "markup.bold.pgn"]
        expect(tokens[2]).toEqual value: "*-*", scopes: ["source.pgn", "markup.bold.pgn", "string.quoted.double.pgn"]

      it "plain moves", ->
        {tokens} = grammar.tokenizeLine("1.f3 e5 2.g4 Qh4# 0-1")
        expect(tokens[0]).toEqual value: "1.", scopes: ["source.pgn", "markup.bold.pgn"]
        expect(tokens[1]).toEqual value: "f3 e5 2.g4 Qh4# ", scopes: ["source.pgn", "markup.bold.pgn"]
        expect(tokens[2]).toEqual value: "0-1", scopes: ["source.pgn", "markup.bold.pgn", "string.quoted.double.pgn"]

      it "white variation", ->
        {tokens} = grammar.tokenizeLine("1.f3 e5 2.g4 (2.g3) Qh4# 0-1")
        expect(tokens[0]).toEqual value: "1.", scopes: ["source.pgn", "markup.bold.pgn"]
        expect(tokens[1]).toEqual value: "f3 e5 2.g4 ", scopes: ["source.pgn", "markup.bold.pgn"]
        expect(tokens[2]).toEqual value: "(", scopes: ["source.pgn", "markup.bold.pgn", "markup.italic.pgn"]
        expect(tokens[3]).toEqual value: "2.g3", scopes: ["source.pgn", "markup.bold.pgn", "markup.italic.pgn"]
        expect(tokens[4]).toEqual value: ")", scopes: ["source.pgn", "markup.bold.pgn", "markup.italic.pgn"]
        expect(tokens[5]).toEqual value: " Qh4# ", scopes: ["source.pgn", "markup.bold.pgn"]
        expect(tokens[6]).toEqual value: "0-1", scopes: ["source.pgn", "markup.bold.pgn", "string.quoted.double.pgn"]

      it "black variation", ->
        {tokens} = grammar.tokenizeLine("1.f3 e5 2.g4 Qh4# (2... Ke7) 0-1")
        expect(tokens[0]).toEqual value: "1.", scopes: ["source.pgn", "markup.bold.pgn"]
        expect(tokens[1]).toEqual value: "f3 e5 2.g4 Qh4# ", scopes: ["source.pgn", "markup.bold.pgn"]
        expect(tokens[2]).toEqual value: "(", scopes: ["source.pgn", "markup.bold.pgn", "markup.italic.pgn"]
        expect(tokens[3]).toEqual value: "2... Ke7", scopes: ["source.pgn", "markup.bold.pgn", "markup.italic.pgn"]
        expect(tokens[4]).toEqual value: ")", scopes: ["source.pgn", "markup.bold.pgn", "markup.italic.pgn"]
        expect(tokens[5]).toEqual value: " ", scopes: ["source.pgn", "markup.bold.pgn"]
        expect(tokens[6]).toEqual value: "0-1", scopes: ["source.pgn", "markup.bold.pgn", "string.quoted.double.pgn"]

      it "comments", ->
        {tokens} = grammar.tokenizeLine("1.f3 {Unusual.} e5 2.g4 Qh4# {Short game.} 0-1")
        expect(tokens[0]).toEqual value: "1.", scopes: ["source.pgn", "markup.bold.pgn"]
        expect(tokens[1]).toEqual value: "f3 ", scopes: ["source.pgn", "markup.bold.pgn"]
        expect(tokens[2]).toEqual value: "{", scopes: ["source.pgn", "markup.bold.pgn", "comment.block.documentation.pgn"]
        expect(tokens[3]).toEqual value: "Unusual.", scopes: ["source.pgn", "markup.bold.pgn", "comment.block.documentation.pgn"]
        expect(tokens[4]).toEqual value: "}", scopes: ["source.pgn", "markup.bold.pgn", "comment.block.documentation.pgn"]
        expect(tokens[5]).toEqual value: " e5 2.g4 Qh4# ", scopes: ["source.pgn", "markup.bold.pgn"]
        expect(tokens[6]).toEqual value: "{", scopes: ["source.pgn", "markup.bold.pgn", "comment.block.documentation.pgn"]
        expect(tokens[7]).toEqual value: "Short game.", scopes: ["source.pgn", "markup.bold.pgn", "comment.block.documentation.pgn"]
        expect(tokens[8]).toEqual value: "}", scopes: ["source.pgn", "markup.bold.pgn", "comment.block.documentation.pgn"]
        expect(tokens[9]).toEqual value: " ", scopes: ["source.pgn", "markup.bold.pgn"]
        expect(tokens[10]).toEqual value: "0-1", scopes: ["source.pgn", "markup.bold.pgn", "string.quoted.double.pgn"]

      it "annotations", ->
        {tokens} = grammar.tokenizeLine("1.f3 $2 e5 $1 2.g4 $4 Qh4# $3 0-1")
        expect(tokens[0]).toEqual value: "1.", scopes: ["source.pgn", "markup.bold.pgn"]
        expect(tokens[1]).toEqual value: "f3 ", scopes: ["source.pgn", "markup.bold.pgn"]
        expect(tokens[2]).toEqual value: "$2", scopes: ["source.pgn", "markup.bold.pgn", "variable.other.pgn"]
        expect(tokens[3]).toEqual value: " e5 ", scopes: ["source.pgn", "markup.bold.pgn"]
        expect(tokens[4]).toEqual value: "$1", scopes: ["source.pgn", "markup.bold.pgn", "variable.other.pgn"]
        expect(tokens[5]).toEqual value: " 2.g4 ", scopes: ["source.pgn", "markup.bold.pgn"]
        expect(tokens[6]).toEqual value: "$4", scopes: ["source.pgn", "markup.bold.pgn", "variable.other.pgn"]
        expect(tokens[7]).toEqual value: " Qh4# ", scopes: ["source.pgn", "markup.bold.pgn"]
        expect(tokens[8]).toEqual value: "$3", scopes: ["source.pgn", "markup.bold.pgn", "variable.other.pgn"]
        expect(tokens[9]).toEqual value: " ", scopes: ["source.pgn", "markup.bold.pgn"]
        expect(tokens[10]).toEqual value: "0-1", scopes: ["source.pgn", "markup.bold.pgn", "string.quoted.double.pgn"]
