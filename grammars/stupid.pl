grammar_l(s,  [np,  vp]).
grammar_l(np, [det, n]).
grammar_l(np, [np, pp]).
grammar_l(vp, [v]).
grammar_l(vp, [v, np]).
grammar_l(vp, [v, np, pp]).
grammar_l(pp, [p, np]).

lexicon_l(det, 'het').
lexicon_l(det, 'de').
lexicon_l(n,   'man').
lexicon_l(v,   'ziet').
lexicon_l(n,   'vrouw').
lexicon_l(n,   'verrekijker').
lexicon_l(p,   'met').
