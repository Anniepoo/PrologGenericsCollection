:- module(
  rdfs_build,
  [
% CLASS HIERARCHY %
    rdfs_assert_class/2, % +Class:uri
                         % +Graph:graph
    rdfs_assert_individual/3, % +Individual:uri
                              % +Class:uri
                              % +Graph:graph
    rdfs_assert_property_class/2, % +PropertyClass:uri
                                  % +Graph:graph
    rdfs_assert_subclass/3, % +Class:uri
                            % +SuperClass:uri
                            % +Graph:graph

% LABELS %
    rdfs_assert_label/3, % +Subject:oneof([bnode,uri])
                         % +Label:atom
                         % +Graph:graph
    rdfs_assert_label/4, % +Subject:oneof([bnode,uri])
                         % +Language:atom
                         % +Label:atom
                         % +Graph:graph
    rdfs_retractall_label/3, % +Subject:oneof([bnode,uri])
                             % +Label:atom
                             % +Graph:graph
    rdfs_retractall_label/4, % +Subject:oneof([bnode,uri])
                             % +Language:atom
                             % +Label:atom
                             % +Graph:graph

% PROPERTY HIERARCHY %
    rdfs_assert_property/2, % +Property:uri
                            % +Graph:atom
    rdfs_assert_subproperty/3 % +Property:uri
                              % +SuperProperty:uri
                              % +Graph:graph
  ]
).

/** <module> RDFS build

Predicates for asseritng RDFS statements in an easy way.

Higher-level predicates for building RDF graphs.
These predicates use the lower-level predicates from RDF_WRITE.

A class C is asserted by (1) a triple of the form <C, rdf:type, C'>, such that
rdfs_subClassOf(C', rdfs:Class), and by (2) a triple of the form
<C, rdfs:subClassOf, C'> such that rdfs_subClassOf(C', rdfs:Resource).

For example =|rdf:XMLLiteral|=:

~~~
< rdf:XMLLiteral, rdf:type,        rdfs:Datatype >
< rdf:XMLLiteral, rdfs:subClassOf, rdfs:Literal  >
~~~

A property P is asserted by a triple of the form <P, rdf:type, P'>, such that
rdfs_subPropertyOf(P', rdf:Property).

A property hierarchy with parent _P0_ and children _P1_, ..., _Pn_ is asserted
using the following triples:
    * =|< P0,      rdf:type,           P       >|=
      where =P= is a subclass of =|rdf:Property|=.
    * =|< P0Class, rdfs:subClassOf,    P       >|=
      for the same =P=.
    * =|< P0Class, rdf:type,           C       >|=
      where =C= is a subclass of =|rdfs:Class|=.
    * =|< Pi,      rdf:type,           P0Class >|=
      for every _i_ between _1_ and _n_ (inclusive).
    * =|< Pi,      rdfs:subPropertyOf, P       >|=
      for every _i_ between _1_ and _n_ (inclusive).

@author Wouter Beek
@version 2011/08, 2012/01, 2012/03, 2012/09, 2012/11-2013/02, 2013/05-2013/06
*/

:- use_module(library(semweb/rdf_db)).
:- use_module(rdf(rdf_build)).
:- use_module(rdf(rdf_datatype)).
:- use_module(rdf(rdf_export)).
:- use_module(rdfs(rdfs_read)).
:- use_module(xml(xml_namespace)).

:- xml_register_namespace(rdf, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#').
:- xml_register_namespace(rdfs, 'http://www.w3.org/2000/01/rdf-schema#').

% CLASS HIERARCHY %
:- rdf_meta(rdfs_assert_class(r,+)).
:- rdf_meta(rdfs_assert_individual(r,r,+)).
:- rdf_meta(rdfs_assert_property_class(r,+)).
:- rdf_meta(rdfs_assert_subclass(r,r,+)).
% LABELS %
:- rdf_meta(rdfs_assert_label(r,+,+)).
:- rdf_meta(rdfs_assert_label(r,+,+,+)).
:- rdf_meta(rdfs_retractall_label(r,+,+)).
:- rdf_meta(rdfs_retractall_label(r,+,+,+)).
% PROPERTY HIERARCHY %
:- rdf_meta(rdfs_assert_property(r,+)).
:- rdf_meta(rdfs_assert_subproperty(r,r,+)).

:- load_rdfs_schema.



% CLASS HIERARCHY %

rdfs_assert_class(Class, Graph):-
  % Materialization
  %rdfs_assert_individual(Class, rdfs:'Class', Graph),
  rdfs_assert_subclass(Class, rdfs:'Resource', Graph).

%! rdfs_assert_individual(+Individual:uri, +Class:class, +Graph:graph) is det.
% Asserts an individual/class relationship.
%
% @arg Individual An instance resource.
% @arg Class A class resource.
% @arg Graph The atomic name of an RDF graph.

rdfs_assert_individual(Individual, Class, Graph):-
  rdf_assert(Individual, rdf:type, Class, Graph).

rdfs_assert_property_class(PropertyClass, Graph):-
  % Materialization
  %rdfs_assert_individual(PropertyClass, rdfs:'Class', Graph),
  rdfs_assert_subclass(PropertyClass, rdf:'Property', Graph).

rdfs_assert_subclass(Class, SuperClass, Graph):-
  rdf_assert(Class, rdfs:subClassOf, SuperClass, Graph).



% LABELS %

%! rdfs_assert_label(
%!   +Subject:oneof([bnode,uri]),
%!   +Label:atom,
%!   +Grap:atom
%! ) is det.
% Assert the subject's label description.
%
% @arg Subject A resource.
% @arg Label An atomic description of a resource.
% @arg Graph The atomic name of an RDF graph.
% @see rdfs_assert_label/4 also specifies the label.

rdfs_assert_label(Subject, Label, Graph):-
  rdf_assert_literal(Subject, rdfs:label, Label, Graph).

%! rdfs_assert_label(
%!   +Subject:oneof([bnode,uri]),
%!   +Language:atom,
%!   +Label:atom,
%!   +Grap:atom
%! ) is det.
% Assert the subject's label description in the given label.
%
% @arg Subject A resource.
% @arg Language The atomic name of a language.
% @arg Label An atomic description of a resource.
% @arg Graph The atomic name of an RDF graph.

rdfs_assert_label(Subject, Language, Label, Graph):-
  rdf_assert_literal(Subject, rdfs:label, Language, Label, Graph).

rdfs_retractall_label(Subject, Label, Graph):-
  rdf_retractall_literal(Subject, rdfs:label, Label, Graph).

rdfs_retractall_label(Subject, Language, Label, Graph):-
  rdf_retractall_literal(Subject, rdfs:label, Language, Label, Graph).



% PROPERTY HIERARCHY %

rdfs_assert_property(Property, Graph):-
  rdfs_assert_individual(Property, rdf:'Property', Graph).

%! rdfs_assert_subproperty(
%!   +Property:property,
%!   +SuperProperty:property,
%!   +Graph:graph
%! ) is det.
% Creates a new property that is a subproperty of the given parent property.
%
% @arg Property An RDF property.
% @arg SuperProperty An RDF property.
% @arg Graph The atomic name of an RDF graph.

rdfs_assert_subproperty(Property, SuperProperty, Graph):-
  % Materialization
  %rdf_assert(Property, rdf:type, rdf:'Property', Graph),
  rdf_assert(Property, rdfs:subPropertyOf, SuperProperty, Graph).

