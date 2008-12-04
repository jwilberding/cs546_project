-module (thread_creation).
-export ([start/1, run/0]).

start (X) ->
    {StartMega, StartSec, StartMicro} = now(),
    create_threads (X),
    {EndMega, EndSec, EndMicro} = now(),
    Time = (EndMega * 1000000000000   + EndSec * 1000000   + EndMicro) -
        (StartMega * 1000000000000 + StartSec * 1000000 + StartMicro),    
    io:format("Time in microseconds:  ~p~n", [Time]).

create_threads (0) ->
    ok;
create_threads (X) ->
    spawn (thread_creation, run, []),
    create_threads (X-1).

run () ->
    I=0,
    I+1.    
