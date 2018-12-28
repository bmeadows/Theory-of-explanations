
prettyprintln(String) :- prettyprint(String), nl.

prettyprint(String) :- atom(String), writef(String), !.
prettyprint(Term) :- write(Term).

prettyprintstars :- prettyprintln('************************').
