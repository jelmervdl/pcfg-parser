:- include('grammars/penn-pcfg.pl').
%:- include('grammars/stupid.pl').

:- dynamic(serial_/1).
serial_(0).
serial(N) :-
	serial_(M),
	retractall(serial_(M)),
	N is M + 1,
	asserta(serial_(N)).

grammar(TopCat, SubCatNodes, Attr) :-
	nodify(SubCats, SubCatNodes),
	grammar_l(TopCat, SubCats, Attr).

nodify([], []).
nodify([Cat|Cats], [n(Cat,_,_)|Nodes]) :-
	nodify(Cats, Nodes).

categorise([], []).
categorise([Word|Words],[n(Cat,t(Word),Attr)|Cats]) :-
	lexicon_l(Cat,Word,Attr),
	categorise(Words,Cats).

parse(Sentence, Result) :-
	categorise(Sentence, Cats),
	reduce(Cats, Result).

reduce([n(s,X,Attr)], n(s,X,Attr)).
reduce(Categories, Result) :-
	subsequence(SubCats,Categories),
	grammar(TopCat, SubCats, Attr),
	%subset(SubCats,Categories), % doesn't work, propably because it binds the unbound variables in the nodes.
	replace(Categories, SubCats, [n(TopCat, SubCats, Attr)], Reduced),
	reduce(Reduced, Result).

% subsequence starts from the right and the longest possible subsequence from there.
subsequence__(Sub,Rest) :-
	subsequence_(Sub,Rest).
subsequence__([],_).
subsequence_([S|Sub],[S|Rest]) :-
	subsequence__(Sub,Rest).
subsequence(Sub,[_|Rest]) :-
	subsequence(Sub,Rest).
subsequence(Sub,Rest) :-
	subsequence_(Sub,Rest).

replace_([], [], [], []).

replace_([I|Input], [I|Source], [], Output) :-
	replace_(Input, Source, [], Output).

replace_(Input, [], [D|Dest], [D|Output]) :-
	replace_(Input, [], Dest, Output).

replace_([I|Input], [], [], [I|Output]) :-
	replace_(Input, [], [], Output).

replace_([I|Input], [I|Source], [D|Dest], [D|Output]) :-
	replace_(Input, Source, Dest, Output).

replace(Input, Source, Dest, Output) :-
	replace_(Input, Source, Dest, Output).

replace([I|Input], Source, Dest, [I|Output]) :-
	replace(Input, Source, Dest, Output).

test_replace :-
	replace([x,a,a,b,z], [a,b], [c], [x,a,c,z]).

test_parse :-
	sentence(_, Sentence),
	parse(Sentence, Result),
	n_to_alpino(Result, XML),
	xml_write(user, [XML], []).

test_subsequence :-
	subsequence([a,b], [a,b,c,d]),
	subsequence([b,c], [a,b,c,d]),
	subsequence([c,d], [a,b,c,d]),
	subsequence([a,b], [a,b]),
	not(subsequence([], [a,b,c])),
	not(subsequence([b,a], [a,b])),
	not(subsequence([a,c], [a,b,c,d])).

%find_all_parses(Sentence) :-
%	findall(Parse, parse(Sentence, Parse), Parses),
%	sort(Parses, Pruned),
%	export_parses_to_alpino('parses/parse_~d.xml', 0, Pruned).

find_all_parses(Sentence) :-
(
	parse(Sentence, Parse),
	serial(N),
	export_parses_to_alpino('parses/parse_~d.xml', N, [Parse]),
	fail
) ; true.

export_parses_to_alpino(_, _, []).
export_parses_to_alpino(Template, Counter, [Parse|Parses]) :-
	n_to_alpino(Parse, XML),
	format(atom(Filename), Template, Counter),
	open(Filename, write, File),
	xml_write(File, [XML], []),
	close(File),
	Incremented is Counter + 1,
	export_parses_to_alpino(Template, Incremented, Parses).

n_to_alpino(Root, element(alpino_ds, [version=1.3], XMLNodes)) :-
	n_to_xml([Root], XMLNodes).

n_to_xml([], []).
n_to_xml([n(Cat,t(Word),Attr)|Nodes], [element(node, [cat=Cat,lemma=Word|Attr], [])|XMLNodes]) :-
	n_to_xml(Nodes, XMLNodes).
n_to_xml([n(Cat,Children,Attr)|Nodes], [element(node, [cat=Cat|Attr],XMLChildren)|XMLNodes]) :-
	n_to_xml(Children, XMLChildren),
	n_to_xml(Nodes, XMLNodes).

% Converters the variable_sentence into normal sentences.
sentence(N,Sentence):-
	variable_sentence(N,Parts),
	build_sentence(Parts,Sentence).

build_sentence([],[]).

build_sentence([Option|Options],Sentence):-
	is_list(Option),
	!,
	member(Part,Option),
	build_sentence(Options,Parts),
	append(Part,Parts,Sentence).

build_sentence([Word|Options], [Word|Sentence]):-
	build_sentence(Options, Sentence).