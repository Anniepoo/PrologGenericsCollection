:- module(
  assoc_multi,
  [
    get_assoc/3, % ?Key
                 % +Assoc
                 % ?Value
    put_assoc/3, % +Key
                 % +AssocName:atom
                 % +Value
    put_assoc/4, % +Key
                 % +OldAssoc
                 % +Value
                 % ?NewAssoc
    register_assoc/1 % ?Assoc
  ]
).

/** <module> ASSOC MULTI

An association list with multiple values per keys, using ordered sets.

This extends library assoc by overloading get_assoc/3 and put_assoc/4,
and by adding ord_member/2.

@author Wouter Beek
@version 2013/04-2013/05
*/

:- reexport(library(assoc), except([get_assoc/3, put_assoc/4])).
:- use_module(library(ordsets)).

:- dynamic(current_assoc(_Name, _Assoc)).



%! get_assoc(?Key, +Assoc, ?Value) is nondet.

get_assoc(Key, Assoc, Value):-
  assoc:get_assoc(Key, Assoc, Ordset),
  ord_member(Value, Ordset).

%! ord_member(?Member, ?List:list) is nondet.

ord_member(Value, Ordset):-
  nonvar(Value),
  !,
  ord_memberchk(Value, Ordset).
ord_member(Value, Ordset):-
  member(Value, Ordset).

%! put_assoc(+Key, +AssocName:atom, +Value) is det.

put_assoc(Key, AssocName, Value):-
  retract(current_assoc(AssocName, OldAssoc)),
  put_assoc(Key, OldAssoc, Value, NewAssoc),
  assert(current_assoc(AssocName, NewAssoc)).

%! put_assoc(+Key, +OldAssoc, +Value, ?NewAssoc) is semidet.

% Put the given value into the existing ordset.
put_assoc(Key, OldAssoc, Value, NewAssoc):-
  assoc:get_assoc(Key, OldAssoc, OldOrdset),
  !,
  ord_add_element(OldOrdset, Value, NewOrdset),
  assoc:put_assoc(Key, OldAssoc, NewOrdset, NewAssoc).
% Create a new ordset.
put_assoc(Key, OldAssoc, Value, NewAssoc):-
  assoc:put_assoc(Key, OldAssoc, [Value], NewAssoc).

register_assoc(Name):-
  empty_assoc(EmptyAssoc),
  assert(current_assoc(Name, EmptyAssoc)).

