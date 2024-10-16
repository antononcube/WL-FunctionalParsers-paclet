(*
   This package provides an implementation of a system of functional parsers.

   The implementation follows closely the article:
     "Functional parsers" by Jeroen Fokker
      http://www.staff.science.uu.nl/~fokke101/article/parsers/
*)

BeginPackage["AntonAntonov`FunctionalParsers`"];

ParseSymbol::usage = "ParseSymbol[s] parses a specified symbol s.";
ParseFuzzySymbol::usage = "ParseFuzzySymbol[s, n] parses a specified symbol s if the edit distance with s is less or equal n.";
ParseToken::usage = "ParseToken[t] parses the token t.";
ParsePredicate::usage = "ParsePredicate[p] parses strings that give True for the predicate p.";
ParseEpsilon::usage = "ParseEpsilon parses and empty string.";
ParseSucceed::usage = "ParseSucceed[v] does not consume input and always returns v.";
ParseFail::usage = "ParseFail fails to recognize any input string.";

ParseComposeWithResults::usage = "ParseComposeWithResults[p_][res : {{_, _} ..}]  is building block function for ParseSequentialComposition.";
ParseSequentialComposition::usage = "ParseSequentialComposition parses a sequential composition of two or more parsers.";
ParseAlternativeComposition::usage = "ParseAlternativeComposition parses a composition of two or more alternative parsers.";


ParseSpaces::usage = "ParseSpaces[p] is a transformation of the parser p: the leading spaces of the input are dropped then the parser p is applied.";
ParseJust::usage = "ParseJust[p] is a transformation of the parser p: those parts of output of p are selected that have empty rest strings.";
ParseApply::usage = "ParseApply[f,p] applies the function f to each of the outputs of p.\
 ParseApply[{fNo, fYes}, p] applies the function fNo not unsuccessful parsing and the function fYes the output of successful parsing using p.";
ParseModify::usage = "ParseModify[f,p] applies the function f to the list of all outputs of p.";
ParseSome::usage = "ParseSome[p] applies ParseJust[p] and takes the first non-empty output if it exists.";
ParseShortest::usage = "ParseShortest[p] takes the output with the shortest rest string.";
ParseSequentialCompositionPickLeft::usage = "ParseSequentialCompositionPickLeft[p1,p2] drops the output of the p2 parser.";
ParseSequentialCompositionPickRight::usage = "ParseSequentialCompositionPickRight[p1,p2] drops the output of the p1 parser.";

ParseChoice::usage = "ParseChoice[p1,p2,p3,...] a version of ParseAlternativeComposition for more than two parsers.";

CircleDot::usage = "CircleDot[f_, p_] applies the function f to the output of p. It can be entered with \"Exc c . Esc\" .";
CircleTimes::usage = "CircleTimes[p1,p2,p3] sequential composition of the parsers p1, p2, p3, ... It can be entered with \"Exc c * Esc\" .";
CirclePlus::usage = "CirclePlus[p1,p2,p3] alternatives composition of the parsers p1, p2, p3, ... It can be entered with \"Exc c + Esc\" .";
LeftTriangle::usage = "LeftTriangle[p1_, p2_] drops the output of the right parser, p2. It can be entered with \"\:22B2\".";
RightTriangle::usage = "RightTriangle[p1_, p2_] drops the output of the left parser, p1. It can be entered with \"\:22B3\".";

ParsePack::usage = "ParsePack[s1,p,s2] parses the sequential composition of s1, p, s2 and drops the output of s1 and s2.";
ParseParenthesized::usage = "ParseParenthesized[p] parses with p input enclosed in parentheses \"(\",\")\".";
ParseBracketed::usage = "ParseBracketed[p] parses with p input enclosed in brackets \"[\",\"]\".";
ParseCurlyBracketed::usage = "ParseCurlyBracketed[p] parses with p input enclosed in curly brackets \"{\",\"}\".";

ParseOption::usage = "ParseOption[p] is optional parsing of p.";
ParseOption1::usage = "ParseOption1[p] is optional parsing of p. (Different implementation of ParseOption.)";

ParseMany1::usage = "ParseMany1[p] attempts to parse one or many times with p.";
ParseMany::usage = "ParseMany[p] attempts to parse zero or many times with p.";
ParseManyByBranching::usage = "ParseManyByBranching[p] parsing many times with p and following branches.";

ParseListOf::usage = "ParseListOf[p_, sep_] parse a list of elements parsed by p and separated by elements parsed by sep.";

ParseChainLeft::usage = "ParseChainLeft[p_, sep_] parse a nested application of the function with a name parsed by sep.";
ParseChain1Left::usage = "ParseChain1Left[p_, sep_] parse a nested application of the function with a name parsed by sep.";
ParseChainRight::usage = "ParseChainRight[p_, sep_] parse a nested application of the function with a name parsed by sep.";

ParseRecursiveDefinition::usage = "ParseRecursiveDefinition[pname, rhs] makes a parser with name pname defined by rhs that can be used in recursive definitions.";

ToTokens::usage = "ToTokens[text] breaks down text into tokens. ToTokens[text,terminals] breaks down text using specified terminals. \
ToTokens[text,\"EBNF\"] has a special implementation for parsing EBNF code. (This function is becoming obsolete, use ParseToTokens.)";

ParseToTokens::usage = "ParseToTokens[text, terminalDelimiters, whitespaces] breaks down text into tokens using specified terminal symbols and white spaces.";
ParseToEBNFTokens::usage = "ParseToEBNFTokens[text, whitespaces] breaks down text into tokens using EBNF terminal symbols and specified white spaces.";

ParsingTestTable::usage = "ParsingTestTable[p, s, opts] parses a list of strings with the parser p and tabulates the result. \
The options allow to specify the terminal symbols, tokenizer function, and table layout.";

EBNFNonTerminal::usage = "EBNFNonTerminal head for parsers for non-terminal symbols of EBNF grammars.";
EBNFTerminal::usage = "EBNFTerminal head for parsers for terminal symbols of EBNF grammars.";
EBNFOption::usage = "EBNFOption head for parsers for optional symbols of EBNF grammars.";
EBNFRepetition::usage = "EBNFRepetition head for parsers for repeating symbols of EBNF grammars.";
EBNFSequence::usage = "EBNFSequence head for parsers for sequential composition of symbols of EBNF grammars.";
EBNFAlternatives::usage = "EBNFAlternatives head for parsers for alternatives sequential composition of symbols of EBNF grammars.";
EBNFRule::usage = "EBNFRule head for parsers of EBNF grammar rules.";
EBNF::usage = "Head symbol used to for parsed EBNF grammars.";

EBNFNonTerminalInterpreter::usage = "EBNFNonTerminal generates parsers for non-terminal symbols of EBNF grammars.";
EBNFTerminalInterpreter::usage = "EBNFTerminal generates parsers for terminal symbols of EBNF grammars.";
EBNFOptionInterpreter::usage = "EBNFOption generates parsers for optional symbols of EBNF grammars.";
EBNFRepetitionInterpreter::usage = "EBNFRepetition generates parsers for repeating symbols of EBNF grammars.";
EBNFSequenceInterpreter::usage = "EBNFSequence generates parsers for sequential composition of symbols of EBNF grammars.";
EBNFAlternativesInterpreter::usage = "EBNFAlternatives generates parsers for alternatives sequential composition of symbols of EBNF grammars.";
EBNFRuleInterpreter::usage = "EBNFRule generates parsers of EBNF grammar rules.";

SetParserModifier::usage = "SetParserModifier[p_Symbol, f_] sets the function f to modify the output of the parser p. (Replaces the previous modifier.)";
AddParserModifier::usage = "AddParserModifier[p_Symbol, f_] makes the function f to modify the output of the parser p.";

InterpretWithContext::usage = "InterpretWithContext[pout_,cr_] interprets the parser output pout with the context rules cr.";

EBNFContextRules::usage = "Context rules for EBNF parser generation.";

ParseEBNF::usage = "ParseEBNF[gr:{_String..}] parses the EBNF grammar gr.";
GenerateParsersFromEBNF::usage = "GenerateParsersFromEBNF[gr:{_String..}] generate parsers the EBNF grammar gr.";

GrammarNormalize::usage = "Remove special character sequences from an EBNF grammar string.";

GrammarRandomSentences::usage = "GrammarRandomSentences[ gr: _String | _EBNF, n_Integer] generates n random sentences using the grammar gr.";

Begin["`Private`"];


Clear["Parse?*"];


(************************************************************)
(* Basic parsers                                            *)
(************************************************************)

ParseSymbol[a_] :=
    Function[If[Length[#] > 0 && a === First[#], {{Rest[#], a}}, {}]];

ParseFuzzySymbol[a_, n_Integer : 2] :=
    Function[If[Length[#] > 0 && EditDistance[a, First[#]] <= n, {{Rest[#], a}}, {}]];

ParseToken[k_][xs_] :=
    With[{n = Length[k]},
      If[Length[xs] >= n && k == Take[xs, n], {{Drop[xs, n], k}}, {}]];

ParsePredicate[pred_][xs_] :=
    If[TrueQ[Length[xs] > 0 && pred[First[xs]]], {{Rest[xs], First[xs]}}, {}];

(*
  Note that
  ParseSymbol[a] = ParsePredicate[# == a &]
*)

ParseEpsilon = Function[{xs}, {{xs, {}}} ];

ParseSucceed[v_] := Function[{xs}, {{xs, v}}];

ParseFail[xs_] := {};


(************************************************************)
(* Parse combinators                                        *)
(************************************************************)

ParseComposeWithResults[p_][{}] := {};
ParseComposeWithResults[p_][res : {{_, _} ..}] :=
    Block[{t},
      Flatten[#, 1] &@
          Map[
            Function[{r},
              If[r === {}, {},
                t = p[r[[1]]];
                If[t === {}, {},
                  Map[{#[[1]], {r[[2]], #[[2]]}} &, t]
                ]]],
            res]
    ];
ParseSequentialComposition[p1_][xs_] := p1[xs];

ParseSequentialComposition[args__][xs_] :=
    With[{parsers = {args}},
      Fold[ParseComposeWithResults[#2][#1] &, First[parsers][xs],
        Rest[parsers]]
    ] /; Length[{args}] > 1;

ParseAlternativeComposition[args__][xs_] := Join @@ Map[#[xs] &, {args}];



(************************************************************)
(* Next combinators                                         *)
(************************************************************)
(* ParseSpaces[p_][xs_]:=p[NestWhile[Rest,xs,First[#]==""||First[#]==" "&]]; *)

ParseSpaces[pArg_] :=
    With[{p = pArg},
      Function[p[
        NestWhile[Rest, #,
          Length[#] >
              0 && (First[#] == "" || First[#] == " " ||
              First[#] == "\n") &]]]];

ParseJust[p_][xs_] := With[{res = p[xs]}, Select[res, First[#] === {} &]];

ParseApply[f_, p_][xs_] := Map[{#[[1]], f[#[[2]]]} &, p[xs]];

ParseApply[{fNo_, fYes_}, p_] :=
    With[{res = p[#]},
      Map[{#[[1]], If[#[[2]] === {}, fNo, fYes[#[[2]]]]} &, res]] &;

ParseModify[f_, p_][xs_] := With[{res = p[xs]}, f[res] ];

ParseSome[p_][xs_] :=
    With[{parsed = ParseJust[p][xs]},
      If[Length[parsed] > 0, Take[parsed, 1], parsed]];

ParseShortest[p_] := With[{parsed = p[#]}, If[parsed === {}, parsed, {First@SortBy[parsed, Length[#[[1]]] &]}]] &;

ParseSequentialCompositionPickLeft[p1_, p2_][xs_] := ParseApply[#[[1]] &, ParseSequentialComposition[p1, p2]][xs];

ParseSequentialCompositionPickRight[p1_, p2_][xs_] := ParseApply[#[[2]] &, ParseSequentialComposition[p1, p2]][xs];

ParseChoice[args__][xs_] :=
    With[{parsers = {args}}, Fold[Join[#2[xs], #1] &, ParseFail[xs], Reverse@parsers]];


(************************************************************)
(* Binding for infix notation                               *)
(************************************************************)

CircleDot[f_, p_] := ParseApply[f, p];(* Exc c . Esc *)

CircleTimes[args___] := ParseSequentialComposition[args];(* Exc c * Esc *)

CirclePlus[args___] := ParseAlternativeComposition[args];(* Exc c + Esc *)

LeftTriangle[p1_, p2_] := ParseSequentialCompositionPickLeft[p1, p2]; (* \:22B2 *)

RightTriangle[p1_, p2_] := ParseSequentialCompositionPickRight[p1, p2]; (* \:22B3 *)

(* Note that the precedence pre-assigned of the operators \[CircleDot], \[CircleTimes] and \[CirclePlus] gives the expected grouping:

Block[{a, b, c, d, f, h},
 Print[f\[CircleDot]a\[CircleTimes]b\[CirclePlus]c\[CircleTimes]h\[CircleDot]d]
 ]

ParseAlternativeComposition[ParseSequentialComposition[ParseApply[f,a],b],ParseSequentialComposition[c,ParseApply[h,d]]]
*)

(*
Note that the precedence pre-assigned of the operators \[LeftTriangle] and \[RightTriangle] gives the expected grouping:

Block[{x, y, z},
 Print[x \[RightTriangle] y \[LeftTriangle] z]
 ]

ParseSequentialCompositionPickLeft[ParseSequentialCompositionPickRight[x,y],z]
*)


(************************************************************)
(* Second next combinators                                  *)
(************************************************************)

ParsePack[s1_, p_, s2_] := ParseSequentialCompositionPickLeft[ ParseSequentialCompositionPickRight[s1, p], s2];

ParseParenthesized[p_] := ParsePack[ParseSymbol["("], p, ParseSymbol[")"]];
ParseBracketed[p_] := ParsePack[ParseSymbol["["], p, ParseSymbol["]"]];
ParseCurlyBracketed[p_] := ParsePack[ParseSymbol["{"], p, ParseSymbol["}"]]

ParseOption[p_] := (ParseAlternativeComposition[ParseApply[{#1} &, p], ParseApply[{} &, ParseSucceed[{}]]]);

ParseOption1[p_] := Block[{res = p[#]}, If[TrueQ[res === {}], {{#, {}}}, res]] &;

ParseMany1[p_][xs_] :=
    Module[{t = {}, res},
      res = ParseShortest[ParseOption1[p]][xs];
      While[! (res === {} || res[[1, 2]] === {}),
        AppendTo[t, res[[1, 2]]];
        res = ParseShortest[ParseOption1[p]][res[[1, 1]]];
      ];
      {{res[[1, 1]], t}}
    ];

ParseMany[p_] := ParseMany1[p]\[CirclePlus]ParseSucceed[{}];

Clear[ParseManyByBranching];
ParseManyByBranching[p_][xs_] := ParseManyByBranching[p, {}, 100][xs];
ParseManyByBranching[p_, epsilon_, maxSteps_Integer ][xs_] :=
    Block[{res = {}, pres, pres1, k = 0, p1},
      p1 = ParseAlternativeComposition[ParseSucceed[epsilon], p];
      If[Length[xs] == 0, epsilon,
        pres = p1[xs];
        While[! (pres === {} || And @@ Map[#[[2]] === {} &, pres]) &&
            k < maxSteps,
          k++;
          (*Print[{k, "before:"}, pres];*)
          pres = DeleteCases[pres, {xs, _}];
          res = Join[res, Cases[pres, {{}, ___}]];
          pres = DeleteCases[pres, {{}, ___}];
          pres1 = DeleteCases[pres, {_, {___, {___, epsilon}, epsilon}}];
          (*Print[{k, "after delete:"}, pres1];*)
          If[Length[pres1] == 0 && Length[res] == 0,
            Return[DeleteDuplicates[pres]],
            pres = DeleteDuplicates[ParseComposeWithResults[p1][pres1]]
          ];
          (*Print[{k, "after:"}, pres];*)
        ]
      ];
      DeleteDuplicates[Join[res, pres]]
    ];

ParseListOf[p_, separatorParser_] := (Prepend[#[[2]], #[[1]]] &)\[CircleDot](p\[CircleTimes]ParseMany[separatorParser \[RightTriangle] p])\[CirclePlus]ParseSucceed[{}];

ParseChainLeft[p_, separatorParser_] :=
    Fold[#2[[1]][#1, #2[[2]]] &, #[[1]], #[[2]]] &\[CircleDot](p\[CircleTimes]ParseMany[separatorParser\[CircleTimes]p])\[CirclePlus]ParseSucceed[{}];

ParseChain1Left[p_, separatorParser_] :=
    Fold[#2[[1]][#1, #2[[2]]] &, #[[1]], #[[2]]] &\[CircleDot](p\[CircleTimes]ParseMany1[separatorParser\[CircleTimes]p]);

ParseChainLeft[p_, {separatorParser_, func_}] :=
    (Fold[func[#1, #2[[2]]] &, #[[1]], #[[2]]] &)\[CircleDot](p\[CircleTimes]ParseMany[separatorParser\[CircleTimes]p])\[CirclePlus]ParseSucceed[{}];

ParseChainRight[p_, separatorParser_] :=
    Fold[#2[[2]][#2[[1]], #1] &, #[[2]],
      Reverse[#[[1]]]] &\[CircleDot](ParseMany[p\[CircleTimes]separatorParser]\[CircleTimes]p)\[CirclePlus]ParseSucceed[{}];

ParseChainRight[p_, {separatorParser_, func_}] :=
    Fold[func[#2[[1]], #1] &, #[[2]],
      Reverse[#[[1]]]] &\[CircleDot](ParseMany[p\[CircleTimes]separatorParser]\[CircleTimes]p)\[CirclePlus]ParseSucceed[{}];


(************************************************************)
(* ParseRecursiveDefinition                                 *)
(************************************************************)

SetAttributes[ParseRecursiveDefinition, HoldAll];
ParseRecursiveDefinition[parserName_Symbol, rhs__] :=
    Block[{},
      parserName[xs_] := rhs[xs]
    ];


(************************************************************)
(* Tokenizer                                                *)
(************************************************************)

ToTokens[text_String] := StringSplit[text];
ToTokens[text_String, {}] := StringSplit[text];
ToTokens[text_String, terminals : {_String ...}] :=
    StringSplit[StringReplace[text, Map[# -> " " <> # <> " " &, terminals]]];

ToTokens[text_, "EBNF"] :=
    ToTokens[text, {"|", ",", ";", "=", "[", "]", "(", ")", "{", "}"}];

Clear[ParseToTokens];
ParseToTokens[text_String, terminalDelimiters_ : {}, whitespaces_ : {" ", "\n"}] :=
    Block[{pApplyFunc, pWord, pQWord, pLongTermDelim, pTermDelim, res, procText = Characters[text]},

      pWord =
          ParseSpaces[
            ParseMany1[
              ParsePredicate[!MemberQ[Join[terminalDelimiters, whitespaces], #] &]]];

      pQWord = ParseSpaces[(ParseSymbol["'"]\[CirclePlus]ParseSymbol["\""])\[CircleTimes]
          ParseMany1[ParsePredicate[# != "'" && # != "\"" &]]\[CircleTimes]
          (ParseSymbol["'"]\[CirclePlus]ParseSymbol["\""])];

      If[Length[Select[terminalDelimiters, StringLength[#] > 1 &]] > 0,
        pLongTermDelim =
            ParseAlternativeComposition @@
                Map[ParseApply[StringJoin,
                  ParseSequentialComposition @@ (ParseSymbol /@ Characters[#])] &,
                  Select[terminalDelimiters, StringLength[#] > 1 &]];
        pTermDelim =
            ParseSpaces[ParsePredicate[MemberQ[terminalDelimiters, #] &]\[CirclePlus]pLongTermDelim],
        pTermDelim =
            ParseSpaces[ParsePredicate[MemberQ[terminalDelimiters, #] &]]
      ];
      res = ParseMany1[((If[Length[#] > 0, StringJoin @@ #, #]&)\[CircleDot](pQWord\[CirclePlus]pWord))\[CirclePlus]pTermDelim][procText];
      res[[1, 2]]
    ];

ParseToEBNFTokens[text_, whitespaces_ : {" ", "\n", "\t"}] :=
    ParseToTokens[text, {"|", "&>", "<&", "<@", ",", ";", "=", "[", "]", "(", ")", "{", "}"}, whitespaces ];


(************************************************************)
(* ParsingTestTable                                         *)
(************************************************************)

Clear[ParsingTestTable];

ParsingTestTable::unval = "Unknown value `2` for the option `1`.";

Options[ParsingTestTable] = {FontFamily -> "Times", FontSize -> 16, "Terminals" -> {}, "TokenizerFunction" -> ToTokens, "Layout" -> "Horizontal"};
ParsingTestTable[parser_, statements : {_String ..}, optsArg : OptionsPattern[]] :=
    Block[{res, ff = OptionValue[ParsingTestTable, FontFamily],
      fs = OptionValue[ParsingTestTable, FontSize],
      ts = OptionValue[ParsingTestTable, "Terminals"],
      tokenizerFunc = OptionValue[ParsingTestTable, "TokenizerFunction"],
      layout = OptionValue[ParsingTestTable, "Layout"], opts, ptbl, vptbl},
      opts = {FontFamily -> ff, FontSize -> fs};
      If[ TrueQ[tokenizerFunc === ToTokens],
        res = Map[parser[ToTokens[#, ts]]  &, statements],
        res = Map[parser[tokenizerFunc[#]] &, statements]
      ];
      ptbl =
          Grid[
            Prepend[
              MapThread[Prepend, {Transpose[{Map[Style[#, opts] &, statements], res}], Style[#, Darker[Red], opts] & /@ Range[Length[statements]] }],
              Style[#, Darker[Red], opts] & /@ {"#", "Statement", "Parser output"}
            ],
            Dividers -> {All, {True, True, Sequence @@ Table[False, {Length[statements] - 1}], True}},
            Alignment -> {{Right, Left, Left}}
          ];
      Which[
        TrueQ[layout == "Horizontal"], ptbl,
        TrueQ[layout == "Vertical"],
        ptbl = Transpose[{Map[Style[#, opts] &, statements], res}];
        ptbl[[All, 2]] = Map[ If[ TrueQ[# === {}], {{{}, {}}}, #]&, ptbl[[All, 2]] ];
        vptbl = Flatten[
          Transpose[{statements, ptbl[[All, 2, 1, 2]], ptbl[[All, 2, 1, 1]]}], 1];
        vptbl =
            Transpose[{Flatten[
              Table[{Style[i, Darker[Red], opts], "", ""}, {i, 1, Length[statements]}]],
              Style[#, Gray] & /@
                  Flatten[Table[{"command:", "parsed:", "residual:"}, {Length[vptbl] / 3}]], vptbl}];
        Grid[vptbl, Alignment -> {{Right, Right, Left}}, Spacings -> {0.5, 0.75},
          Dividers -> {{True, True, False, True},
            Join[{True}, Flatten@Table[{False, False, True}, {Length[vptbl]}]]}],
        True,
        Message[ParsingTestTable::unval, "Layout", layout]; ptbl
      ]
    ];


(***************************************************************************)
(* EBNF Parsers with parenthesis and \[RightTriangle] and \[LeftTriangle]  *)
(***************************************************************************)

(* All parsers start with the prefix "pG" followed by a capital letter. ("p" is for "parser", "G" is for "grammar".) *)


Clear[EBNFNonTerminal, EBNFTerminal, EBNFOption, EBNFRepetition, EBNFSequence, EBNFAlternatives, EBNFRule, EBNF];

Clear["pG*"];

(* Parse typeTerminal. All teminals are assumed to be between single or double quotes. *)

EBNFSymbolTest =
    TrueQ[# == "|" || # == "," || # == "=" || # == ";" || # == "\[LeftTriangle]" || # == "\[RightTriangle]" || # == "<&" || # == "&>" ] &;

NonTerminalTest =
    TrueQ[StringMatchQ[#, "<" ~~ (WordCharacter | WhitespaceCharacter | "-" | "_") .. ~~ ">"]] &;

InQuotesTest = TrueQ[StringMatchQ[#, ("'" | "\"") ~~ __ ~~ ("'" | "\"")]] &;

pGTerminal =
    ParsePredicate[StringQ[#] && InQuotesTest[#] && ! EBNFSymbolTest[#] &];

(* Parser typeNonTerminal. I prefer the <xxx> format for non-terminals instead of allowing any string without quotes. *)

pGNonTerminal =
    ParsePredicate[StringQ[#] && NonTerminalTest[#] && ! EBNFSymbolTest[#] &];

pGOption = EBNFOption\[CircleDot]ParseBracketed[pGExpr];

pGRepetition = EBNFRepetition\[CircleDot]ParseCurlyBracketed[pGExpr];

pGNode[xs_] := (EBNFTerminal\[CircleDot]pGTerminal\[CirclePlus]EBNFNonTerminal\[CircleDot]pGNonTerminal\[CirclePlus]ParseParenthesized[pGExpr]\[CirclePlus]pGRepetition\[CirclePlus]pGOption)[xs];

pGTerm = EBNFSequence\[CircleDot]ParseChainRight[pGNode, ParseSymbol[","]\[CirclePlus]ParseSymbol["\[LeftTriangle]"]\[CirclePlus]ParseSymbol["\[RightTriangle]"]\[CirclePlus]ParseSymbol["<&"]\[CirclePlus]ParseSymbol["&>"]];

pGExpr = EBNFAlternatives\[CircleDot]ParseListOf[pGTerm, ParseSymbol["|"]];

pGRule = EBNFRule\[CircleDot](pGNonTerminal\[CircleTimes](ParseSymbol["="] \[RightTriangle] pGExpr)\[CircleTimes](ParseSymbol[";"]\[CirclePlus](ParseSymbol["<@"]\[CircleTimes]ParsePredicate[StringQ[#] &] \[LeftTriangle] ParseSymbol[";"])));

pEBNF = EBNF\[CircleDot]ParseMany1[pGRule];


(********************************************************************************)
(* EBNF grammar parser generators with \[RightTriangle] and \[LeftTriangle]     *)
(********************************************************************************)

Clear[EBNFMakeSymbolName, EBNFNonTerminal, EBNFTerminalInterpreter, EBNFOptionInterpreter, EBNFRepetitionInterpreter,
  EBNFSequenceInterpreter, EBNFAlternativesInterpreter, EBNFRuleInterpreter];

Clear[pNumber, pInteger, pWord, pLetterWord, pIdentifierWord];

pNumber = ToExpression\[CircleDot]ParsePredicate[StringMatchQ[#, NumberString] &];

pInteger = ToExpression\[CircleDot]ParsePredicate[StringMatchQ[#, (DigitCharacter..) | (( "+" | "-" ) ~~ (DigitCharacter..))] &];

pWord = ParsePredicate[StringMatchQ[#, (WordCharacter | "_") ..] &];

pLetterWord = ParsePredicate[StringMatchQ[#, LetterCharacter ..] &];

pIdentifierWord = ParsePredicate[StringMatchQ[#, LetterCharacter ~~ (WordCharacter ... )] &];

Clear[pNumberRange];
pNumberRange[{s_?NumberQ, e_?NumberQ}] :=
    ToExpression\[CircleDot]ParsePredicate[StringMatchQ[#, NumberString] && s <= ToExpression[#] <= e &];

EBNFMakeSymbolName[p_String] :=
    "p" <> ToUpperCase[StringReplace[p, {"<" -> "", ">" -> "", "_" -> "", "-" -> ""}]];

EBNFTerminalInterpreter[parsed_] :=
    Which[
      StringMatchQ[parsed, ("'" | "\"") ~~ "_?NumberQ" ~~ ("'" | "\"")],
      pNumber,
      StringMatchQ[parsed, ("'" | "\"") ~~ "_?IntegerQ" ~~ ("'" | "\"")],
      pInteger,
      StringMatchQ[
        parsed, ("'" | "\"") ~~ "Range[" ~~ NumberString ~~ "," ~~ NumberString ~~ "]" ~~ ("'" | "\"")],
      pNumberRange[
        Flatten@StringCases[
          parsed, ("'" | "\"") ~~ "Range[" ~~ (s : NumberString) ~~ "," ~~ (e : NumberString) ~~ "]" ~~ ("'" | "\"") :> Map[ToExpression, {s, e}]]],
      parsed == "\"_String\"" || parsed == "'_String'",
      ParsePredicate[StringQ[#] &],
      parsed == "\"_WordString\"" || parsed == "'_WordString'", pWord,
      parsed == "\"_LetterString\"" || parsed == "'_LetterString'", pLetterWord,
      parsed == "\"_IdentifierString\"" || parsed == "'_IdentifierString'", pIdentifierWord,
      True, ParseSymbol[
      If[StringMatchQ[parsed, ("'" | "\"") ~~ ___ ~~ ("'" | "\"")],
        StringTake[parsed, {2, -2}], parsed]]
    ];

EBNFNonTerminalInterpreter[parsed_] := ToExpression[EBNFMakeSymbolName[parsed]];

EBNFRepetitionInterpreter[parsed_] := ParseMany1[parsed];

EBNFOptionInterpreter[parsed_] := ParseOption1[parsed];

EBNFSequenceInterpreter[parsedArg_] :=
    Block[{parsed = parsedArg, crules},
      (*Print["before:",parsed];*)

      crules = {ParseSymbol[","] -> "X$$#$#$#1",
        ParseSymbol["\[LeftTriangle]"] -> "X$$#$#$#2", ParseSymbol["<&"] -> "X$$#$#$#2",
        ParseSymbol["\[RightTriangle]"] -> "X$$#$#$#3", ParseSymbol["&>"] -> "X$$#$#$#3"};
      parsed = parsed //. crules;
      (*Print["mid:",parsed];*)

      parsed = parsed /. {"," -> ParseSequentialComposition,
        "\[LeftTriangle]" -> ParseSequentialCompositionPickLeft, "<&" -> ParseSequentialCompositionPickLeft,
        "\[RightTriangle]" -> ParseSequentialCompositionPickRight, "&>" -> ParseSequentialCompositionPickRight};
      parsed = parsed //. (Reverse /@ crules);
      (*Print["after:",parsed];*)
      Which[
        ! ListQ[parsed], parsed,
        Length[parsed] == 1, parsed[[1]],
        True, ParseSequentialComposition @@ parsed
      ]
    ];


EBNFAlternativesInterpreter[parsed_] :=
    Which[
      ! ListQ[parsed], parsed,
      Length[parsed] == 1, parsed[[1]],
      True, ParseAlternativeComposition @@ parsed
    ];

EBNFRuleInterpreter[parsed_] :=
    Block[{lhsSymbolName, lhsSymbol, res},
      lhsSymbolName = EBNFMakeSymbolName[parsed[[1, 1]]];
      With[{sn = lhsSymbolName}, Clear[sn]];
      lhsSymbol = ToExpression[lhsSymbolName];
      (*Print[lhsSymbol];*)
      If[ListQ[parsed[[2]]],
        With[{lhs = lhsSymbol, rhs = parsed[[1, 2]], func = parsed[[2, 2]]},
          lhs[xs_] := ParseApply[ToExpression[func], rhs][xs]];
        res = Row[{lhsSymbolName, " = ", parsed[[1, 2]], parsed[[2, 1]], parsed[[2, 2]]}],
        (* assumed Length[parsed] == 2*)

        With[{lhs = lhsSymbol, rhs = parsed[[1, 2]]}, lhs[xs_] := rhs[xs]];
        res = Row[{lhsSymbolName, " = ", parsed[[1, 2]]}]
      ];
      res
    ];


(************************************************************)
(* Parser definition modification                           *)
(************************************************************)

(* one downvalue per parser is assumed *)
Clear[AddParserModifier];
AddParserModifier[parser_Symbol, func_] :=
    Block[{dvs = Cases[DownValues[parser], _RuleDelayed]},
      If[Length[dvs] == 0, {},
        With[{parserBody = dvs[[1, 2, 0]], parserVar = dvs[[1, 1, 1, 1, 1]]},
          DownValues[
            parser] = {dvs[[1, 1]] :> ParseApply[func, parserBody][parserVar]}
        ]
      ]
    ];

Clear[SetParserModifier];
SetParserModifier[parser_Symbol, func_] :=
    Block[{dvs = Cases[DownValues[parser], _RuleDelayed]},
      Which[
        Length[dvs] == 0, {},
        Length[dvs] > 0 && Head[dvs[[1, 2, 0]]] === ParseApply,
        DownValues[parser] = {ReplacePart[dvs, {1, 2, 0, 1} -> func]},
        True,
        AddParserModifier[parser, func]
      ]
    ];

(************************************************************)
(* Interpretation                                           *)
(************************************************************)

EBNFContextRules =
    {EBNFNonTerminal -> EBNFNonTerminalInterpreter,
      EBNFTerminal -> EBNFTerminalInterpreter,
      EBNFOption -> EBNFOptionInterpreter,
      EBNFRepetition -> EBNFRepetitionInterpreter,
      EBNFSequence -> EBNFSequenceInterpreter,
      EBNFAlternatives -> EBNFAlternativesInterpreter,
      EBNFRule -> EBNFRuleInterpreter};

Clear[InterpretWithContext];
InterpretWithContext[parsed_, contextRules : {_Rule ...}] :=
    Block[{},
      {parsed /. contextRules, {} }
    ];

InterpretWithContext[parsed_, contextRules : {"data" -> {}, "functions" -> {(_Symbol -> _) ...}}] :=
    InterpretWithContext[parsed, "functions" /. contextRules];

InterpretWithContext[parsed_, contextRules : {"data" -> {(_Symbol -> _) ..}, "functions" -> {(_Symbol -> _) ...}}] :=
    Block[{dataVars, res, newData},
      dataVars = ("data" /. contextRules)[[All, 1]];
      {res, newData} =
          Block[Evaluate[dataVars],
            Do[
              Evaluate[r[[1]]] = r[[2]]
              , {r, ("data" /. contextRules)}];
            {parsed /. ("functions" /. contextRules), dataVars}
          ];
      {res, Thread[dataVars -> newData]}
    ];

ParseEBNF[code_] := pEBNF[code];

GenerateParsersFromEBNF[code_] := InterpretWithContext[ pEBNF[code], EBNFContextRules ];


(************************************************************)
(* Random sentences                                         *)
(************************************************************)

Clear[GrammarNormalize];
GrammarNormalize[ebnf_String] := StringReplace[ebnf, {"&>" -> ",", "<&" -> ",", ("<@" ~~ (Except[{">", "<"}] ..) ~~ ";") :> ";"}];
GrammarNormalize[___] := $Failure;

(* Random sentences generator from EBNF grammar (rule based) *)

Clear[RGMakeSymbolName, RGNonTerminal, RGTerminal, RGOption, RGRepetition,
  RGSequence, RGAlternatives, RGRule, EBNF];

Clear[rgInteger, rgNumber, rgString, rgLetterString];
rgInteger := ToString[RandomInteger[{0, 1000}]];
rgNumber := ToString[RandomReal[{0, 1000}]];
rgNumberRange[{s_?NumberQ, e_?NumberQ}] := ToString[RandomInteger[{s, e}]];
rgString := StringJoin @@ RandomSample[Join[CharacterRange["0", "9"], CharacterRange["a", "z"]], RandomInteger[{3, 10}]];
rgLetterString := StringJoin @@ RandomSample[CharacterRange["a", "z"], RandomInteger[{3, 10}]];

RGTerminal[parsed_] :=
    Which[
      StringMatchQ[parsed, ("'" | "\"") ~~ "_?IntegerQ" ~~ ("'" | "\"")],
      rgInteger,

      StringMatchQ[parsed, ("'" | "\"") ~~ "_?NumberQ" ~~ ("'" | "\"")],
      rgNumber,

      StringMatchQ[parsed, ("'" | "\"") ~~ "Range[" ~~ NumberString ~~ "," ~~ NumberString ~~ "]" ~~ ("'" | "\"")],
      rgNumberRange[Flatten@
          StringCases[parsed, ("'" | "\"") ~~ "Range[" ~~ (s : NumberString) ~~ "," ~~ (e : NumberString) ~~ "]" ~~ ("'" | "\"") :> Map[ToExpression, {s, e}]]],

      parsed == "\"_String\"" || parsed == "'_String'" || parsed == "\"_?StringQ\"" || parsed == "'_?StringQ'",
      rgString,

      parsed == "\"_WordString\"" || parsed == "'_WordString'",
      rgString,

      parsed == "\"_LetterString\"" || parsed == "'_LetterString'",
      rgLetterString,

      parsed == "\"_IdentifierString\"" || parsed == "'_IdentifierString'",
      rgLetterString,

      True,
      If[StringMatchQ[parsed, ("'" | "\"") ~~ ___ ~~ ("'" | "\"")], StringTake[parsed, {2, -2}], parsed]

    ];

RGNonTerminal[parsed_] := parsed;

RGRepetition[parsed_] := Flatten@Table[parsed, {RandomInteger[{1, 5}]}];

RGOption[parsed_] := If[RandomInteger[{0, 1}] == 0, parsed, ""];

RGSequence[parsed_] :=
    Which[
      ! ListQ[parsed], parsed,
      Length[parsed] == 1, parsed[[1]],
      True, parsed
    ];

$RGAlternativesRecursionLimit = 50;
$RGAlternativesRecursionLevel = 0;

RGAlternatives[parsed_] :=
    Block[{},
      $RGAlternativesRecursionLevel++;
      Which[
        $RGAlternativesRecursionLevel > $RGAlternativesRecursionLimit,
        RandomChoice[Flatten[Cases[parsed, _String, Infinity]]],

        ! ListQ[parsed], parsed,

        Length[parsed] == 1, parsed[[1]],

        True, RandomChoice[parsed]
      ]
    ];

MakeNonTerminalReplacementRules[parsedEBNFRules_] :=
    Cases[parsedEBNFRules, {s_String, rhs_} :> (EBNFNonTerminal[s] -> rhs), Infinity];

Clear[RGSentence];
RGSentence[parsedEBNF_EBNF, recursionLimit : (_Integer | Automatic | Infinity ) : 20] :=
    Block[{parsedEBNFRules = parsedEBNF[[1]], rrules, rrulesRest, dRRulesRest, EBNFToRGRules, t},

      EBNFToRGRules =
          Dispatch[Thread[{EBNFTerminal, EBNFOption, EBNFRepetition, EBNFSequence} -> {RGTerminal, RGOption, RGRepetition, RGSequence}]];

      rrules = Cases[parsedEBNFRules, {s_String, rhs_} :> (EBNFNonTerminal[s] -> rhs), Infinity];

      rrulesRest = Rest[rrules];
      dRRulesRest = Dispatch[rrulesRest];

      rrulesRest[[All, 2]] = rrulesRest[[All, 2]] /. dRRulesRest;
      PRINT["1.", rrulesRest[[All, 2]]];

      rrulesRest[[All, 2]] = rrulesRest[[All, 2]] /. EBNFToRGRules;
      PRINT["2.", rrulesRest[[All, 2]]];

      If[ IntegerQ[recursionLimit],
        Do[
          rrulesRest[[All, 2]] = rrulesRest[[All, 2]] /. dRRulesRest,
          {i, 0, recursionLimit}
        ],
        (*ELSE*)
        rrulesRest[[All, 2]] = rrulesRest[[All, 2]] //. dRRulesRest
      ];
      PRINT["3.", rrulesRest];

      $RGAlternativesRecursionLimit = If[ NumericQ[recursionLimit], recursionLimit, $RecursionLimit];
      $RGAlternativesRecursionLevel = 0;
      t = Flatten@List[(First[rrules][[2]] /. Dispatch[rrulesRest]) /. EBNFToRGRules //. EBNFAlternatives[s___] :> RGAlternatives[s]];
      PRINT["t=", t];

      (*StringTrim[StringReplace[StringJoin@@Riffle[Which[Head[t]\[Equal]",",
      List@@t,!ListQ[t],{t},True,Flatten[t]]," "],"  "\[Rule]" "]]*)

      t = Flatten@List[t //. (","[x__] :> {x})];
      StringTrim[StringReplace[StringRiffle[t, " "], (WhitespaceCharacter ~~ WhitespaceCharacter ..) -> " "]]
    ];


Clear[GrammarRandomSentences];

GrammarRandomSentences::nargs = "The first argument is expected to be a string (with a grammar in EBNF). \
The second argument is expected to be a positive integer.";

Options[GrammarRandomSentences] = {"RecursionLimit" -> Automatic};

GrammarRandomSentences[ebnfGrammar_String, n_Integer, opts : OptionsPattern[]] :=
    Block[{recursionLimit, EBNFMakeSymbolName, EBNFNonTerminal, EBNFTerminal, EBNFOption,
      EBNFRepetition, EBNFSequence, EBNFAlternatives, EBNFRule, tokens, res},

      recursionLimit = OptionValue[GrammarRandomSentences, "RecursionLimit"];
      If[ !NumericQ[recursionLimit] && !MemberQ[{Automatic, Infinity}, recursionLimit],
        recursionLimit = 20
      ];
      If[ NumericQ[recursionLimit],
        recursionLimit = Ceiling[recursionLimit]
      ];

      Clear[EBNFMakeSymbolName, EBNFNonTerminal, EBNFTerminal, EBNFOption,
        EBNFRepetition, EBNFSequence, EBNFAlternatives, EBNFRule];

      tokens = ParseToEBNFTokens[ebnfGrammar];
      (*res=ParseJust[pEBNF][tokens];*)

      res = ParseEBNF[tokens];

      Table[RGSentence[res[[1, 2]], recursionLimit], {n}]
    ] /; n > 0;

GrammarRandomSentences[parsedEBNFRules_EBNF, n_Integer] :=
    Block[{},
      Table[RGSentence[parsedEBNFRules], {n}]
    ];

GrammarRandomSentences[___] :=
    Block[{},
      Message[GrammarRandomSentences::nargs];
      $Failed
    ];


End[];
EndPackage[];