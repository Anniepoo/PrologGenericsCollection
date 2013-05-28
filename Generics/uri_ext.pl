:- module(
  uri_ext,
  [
    uri_to_file/2, % +URI:uri
                   % +File:atom
    uri_query/3 % +URI:uri
                % +Name:atom
                % -Value:atom
  ]
).

/** <module> URI_EXT

@author Wouter Beek
@version 2013/05
*/

:- use_module(library(http/http_open)).
:- use_module(library(lists)).
:- use_module(library(uri)).



%% uri_to_file(+URI:uri, +File:atom) is det.
% Stores the contents retrieved from the given URI to the given file.

uri_to_file(URI, File):-
  setup_call_cleanup(
    % First perform this setup once/1.
    (
      http_open(URI, In, []),
      open(File, write, Out, [type(binary)])
    ),
    % The try to make this goal succeed.
    copy_stream_data(In, Out),
    % If goal succeeds, then perform this cleanup.
    (
      close(Out),
      close(In)
    )
  ).

%! uri_query(+URI:uri, +Name:atom, -Value:atom) is det.

uri_query(URI, Name, Value):-
  uri_components(URI, Components),
  uri_data(search, Components, QueryString),
  uri_query_components(QueryString, QueryPairs),
  member(Name=Value, QueryPairs).