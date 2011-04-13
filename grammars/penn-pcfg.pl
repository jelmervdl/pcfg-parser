:- load_files([
		'/Users/jelmer/Workspace/bach/dptsg/data/wsj.00.grammar.pl',
		'/Users/jelmer/Workspace/bach/dptsg/data/wsj.00.lexicon.pl'
	]).

grammar_l(Cat, SubCats) :-
	grammer_p(Cat, SubCats, _).

lexicon_l(Cat, Word) :-
	findall(rule(RP,RCat,RWord), lexicon_p(RCat, RWord, RP), Rules),
	sort(Rules,SortedRules),
	reverse(SortedRules,ReversedRules),
	!,
	member(rule(_,Cat,Word), ReversedRules).