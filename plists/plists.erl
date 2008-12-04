-module(plists).
-export([start/0, pmap/2,pforeach/2,npforeach/2]).

pmap(F, L) ->
    S = self(),
    Pids = lists:map(fun(I) -> spawn(fun() -> pmap_f(S, F, I) end) end, L),
    pmap_gather(Pids).

pmap_gather([H|T]) ->
    receive
        {H, Ret} -> [Ret|pmap_gather(T)]
    end;
pmap_gather([]) ->
    [].

pmap_f(Parent, F, I) ->
    Parent ! {self(), (catch F(I))}.

pforeach(F, L) ->
  S = self(),
  Pids = pmap(fun(I) -> spawn(fun() -> pforeach_f(S,F,I) end) end, L),
  pforeach_wait(Pids).

pforeach_wait([H|T]) ->
  receive
    H -> pforeach_wait(T)
  end;
pforeach_wait([]) -> ok.

pforeach_f(Parent, F, I) ->
  _ = (catch F(I)),
  Parent ! self().

npforeach(F, L) ->
  S = self(),
  Pid = spawn(fun() -> npforeach_0(S,F,L) end),
  receive Pid -> ok end.

npforeach_0(Parent,F,L) ->
  S = self(),
  Pids = pmap(fun(I) -> spawn(fun() -> npforeach_f(S,F,I) end) end, L),
  npforeach_wait(S,length(Pids)),
  Parent ! S.

npforeach_wait(_S,0) -> ok;
npforeach_wait(S,N) ->
  receive
    S -> npforeach_wait(S,N-1)
  end.

npforeach_f(Parent, F, I) ->
  _ = (catch F(I)),
  Parent ! Parent.

start() ->
    timer:start(),
    %F = fun(I) -> math:pow(I,I) end,
    {T0,L} = timer:tc(lists,seq,[1,8]),
    {T5,_} = timer:tc(lists,map,[F,L]),
    io:format("seq took ~w microseconds~n",[T5]),
    {T1,_V2} = timer:tc(plists,pmap,[F,L]),
    io:format("pmap took ~w microseconds~n",[T1]),
    {T2,_V1} = timer:tc(plists,pforeach,[F,L]),
    io:format("pforeach took ~w microseconds~n",[T2]),
    {T3,_V1} = timer:tc(plists,npforeach,[F,L]),
    io:format("npforeach took ~w microseconds~n",[T3]),
    ok.
