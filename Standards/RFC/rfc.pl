:- module(
  rfc,
  [
  ]
).

/** <module> RFC

@author Wouter Beek
@version 2013/05
*/

:- use_module(rdfs(rdfs_build)).
:- use_module(xml(xml_namespace)).

:- xml_register_namespace(rfc, 'http://www.ietf.org/rfc/').



init:-
  rdfs_assert_subclass(rfc:'Standard', rdfs:'Class', rfc).
:- init.

