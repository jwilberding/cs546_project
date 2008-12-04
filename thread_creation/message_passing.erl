-module (message_passing).
-export ([start/1, run/1]).

start (X) ->
    {StartMega, StartSec, StartMicro} = now(),
    create_threads (X),
    {EndMega, EndSec, EndMicro} = now(),
    Time = (EndMega * 1000000000000   + EndSec * 1000000   + EndMicro) -
        (StartMega * 1000000000000 + StartSec * 1000000 + StartMicro),    
    wait(X),
    io:format("Time in microseconds:  ~p~n", [Time]).

wait (0) ->
    ok;
wait (X) ->
    receive 
        X ->
            wait (X-1)
    end.

create_threads (0) ->
    ok;
create_threads (X) ->
    spawn (message_passing, run, [self()]),
    create_threads (X-1).

run (PID) ->
    run(PID, 1000).

run (PID, 0) ->
    PID ! 0;
run (PID, X) ->
    PID ! X,
    run (PID, X-1).
