same(X, X).

is_name(_).

is_atom([atom, S]) :- string(S).
make_atom(S, O) :- same(O, [atom, S]), is_atom(O).

is_prod([prod, L, R]) :- is_name(L), is_name(R).
make_prod(L, R, O) :- same(O, [prod, L, R]), is_prod(O).

is_def(D) :- is_atom(D); is_prod(D).

all(_, []).
all(P, [X|XS]) :- call(P, X), all(P, XS).

any(P, [X|XS]) :- call(P, X); any(P, XS).
any(P, [X|XS], E0) :- call(P, E0, X); any(P, XS, E0).

is_bool(X) :- X is 0; X is 1.

is_rule([NAME, DEFS]) :- is_name(NAME), all(is_def, DEFS).
make_rule(NAME, DEFS, O) :- same(O, [NAME, DEFS]), is_rule(O).

is_cnf([EMPTY, START, RULES]) :- is_bool(EMPTY), is_name(START), all(is_rule, RULES).
make_cnf(EMPTY, START, RULES, O) :- same(O, [EMPTY, START, RULES]), is_cnf(O).

look_up([[X, OUT]|_], X, OUT).
look_up([_|YS], X, OUT) :- look_up(YS, X, OUT).

get_defs(CNF, RULE, DEFS) :- same(CNF, [_, _, RULES]), look_up(RULES, RULE, DEFS).

matches([_, S], [atom, S]).
matches([CNF, S], [prod, L, R]) :- 
    string_concat(S0, S1, S),
    string_length(S0, L0),
    string_length(S1, L1),
    L0 > 0,
    L1 > 0,
    accepts(CNF, L, S0),
    accepts(CNF, R, S1).

accepts(CNF, RULE, WORD) :-
    string(WORD),
    is_name(RULE),
    is_cnf(CNF),
    get_defs(CNF, RULE, DEFS),
    any(matches, DEFS, [CNF, WORD]).

accepts([1, _, _], WORD) :- string_length(WORD, 0).
accepts(CNF, WORD) :- same(CNF, [_, START, _]), accepts(CNF, START, WORD).
