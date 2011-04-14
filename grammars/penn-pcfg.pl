:- load_files([
		'/Users/jelmer/Workspace/bach/dptsg/data/wsj.00.grammar.pl',
		'/Users/jelmer/Workspace/bach/dptsg/data/wsj.00.lexicon.pl'
	]).

:-
	findall(rule(RP,RCat,RSubCats), grammer_p(RCat,RSubCats,RP), Rules),
	sort(Rules, SortedRules),
	reverse(SortedRules, ReversedRules),
	dynamic(grammar_rules/1),
	retractall(grammar_rules(_)),
	asserta(grammar_rules(ReversedRules)).

grammar_l(Cat, SubCats, [prob=P]) :-
	grammar_rules(Rules),
	member(rule(P,Cat,SubCats), Rules).

lexicon_l(Cat, Word, [prob=P]) :-
	findall(rule(RP,RCat,RWord), lexicon_p(RCat, RWord, RP), Rules),
	sort(Rules,SortedRules),
	reverse(SortedRules,ReversedRules),
	!,
	member(rule(P,Cat,Word), ReversedRules). %assumes member/2 begins picking at the top.

sentence(1, ['I', see, the, man]).