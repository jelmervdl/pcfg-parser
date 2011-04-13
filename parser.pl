:- include('grammars/stupid.pl').

parse(Sentence, Result) :-
	categorise(Sentence, Cats),
	reduce(Cats, Result).

reduce([n(s,X)], n(s,X)).
reduce(Categories, Result) :-
	grammar(TopCat, SubCats),
	replace(Categories, SubCats, [n(TopCat, SubCats)], Reduced),
	reduce(Reduced, Result).

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
	parse([de,man,ziet,de,vrouw,met,de,verrekijker], Result),
	n_to_alpino(Result, XML),
	xml_write(user, [XML], []).

find_all_parses(Sentence) :-
	findall(Parse, parse(Sentence, Parse), Parses),
	sort(Parses, Pruned),
	export_parses_to_alpino('parses/parse_~d.xml', 0, Pruned).

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
n_to_xml([n(Cat,t(Word))|Nodes], [element(node, [cat=Cat,lemma=Word], [])|XMLNodes]) :-
	n_to_xml(Nodes, XMLNodes).
n_to_xml([n(Cat, Children)|Nodes], [element(node, [cat=Cat],XMLChildren)|XMLNodes]) :-
	n_to_xml(Children, XMLChildren),
	n_to_xml(Nodes, XMLNodes).