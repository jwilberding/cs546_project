-module (thread_creation).
-export ([start/0, run/0]).

start () ->
    create_threads (10000).

create_threads (0) ->
    ok;
create_threads (X) ->
    spawn (thread_creation, run, []),
    create_threads (X-1).

run () ->
    I=0,
    I+1.    
