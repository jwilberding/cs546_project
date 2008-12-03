-module (db_backend).
-include ("wf.inc").
-export ([init/0, start/0, stop/0, validate/2, add_user/3, add_gibe/2, add_followee/2, get_gibes/1, get_all_gibes/1, is_username_used/1, do/1]).

-include_lib ("stdlib/include/qlc.hrl").

-record (users, {username, email_address, password}).
-record (gibes, {key, username, date, gibe}).
-record (following, {username, followee}).
-record (sequence, {count, val}).

%%% Initialize database and tables. Only run once!
init () ->
    mnesia:create_schema ([node()]),
    mnesia:start(),
    %mnesia:delete_table (users), 
    %mnesia:delete_table (gibes),
    %mnesia:delete_table (following),
    mnesia:create_table (users, [{attributes, record_info (fields, users)}, {disc_copies, [node()]}]),
    mnesia:create_table (gibes, [{attributes, record_info (fields, gibes)}, {disc_copies, [node()]}]),
    mnesia:create_table (following, [{attributes, record_info (fields, following)}, {disc_copies, [node()]}]),
    mnesia:create_table (sequence, [{attributes, record_info (fields, sequence)}, {disc_copies, [node()]}]),
    mnesia:stop().   

%%% Start the database
start () ->
    crypto:start(),
    mnesia:start().

%%% Stop the database
stop () ->
    mnesia:stop().

%%% Add a user to the mnesia database
add_user (Username, EmailAddress, Password) ->
    <<PasswordDigest:160>> = crypto:sha(Password),
    Row = #users{username=Username, email_address=EmailAddress, password=PasswordDigest},   
    case write (Row) of
        {atomic, _Val} ->
            ok;
        {aborted, Reason} ->
            io:format ("Adding user failed!~nRow: ~s aborted.~nReason: ~s~n", [Row, Reason]),
            aborted
    end.

add_gibe (Username, Gibe) ->
    case do (qlc:q ([X || X <- mnesia:table(sequence)])) of
        fail ->
            not_valid;
        [] ->
            write (#gibes{key=0, username=Username, date=calendar:local_time(), gibe=Gibe}),
            write (#sequence{count=0});
        [Seq] ->        
            Count = Seq#sequence.count,
            write (#gibes{key=(Count+1), username=Username, date=calendar:local_time(), gibe=Gibe}),
            write (#sequence{count=(Count+1)}),
            delete (sequence, Count)            
    end.   

add_followee (Username, Followee) ->
    write (#following{username=Username, followee=Followee}).

%%% Return true if the Username or EmailAddress match the Input
check (Username, EmailAddress, Input) ->
    if 
        Username == Input ; EmailAddress == Input ->
            true;
        true ->
            false
    end.

%%% Return valid if the Username and Password match, not_valid otherwise
validate (Username, Password) ->
    <<PasswordDigest:160>> = crypto:sha(Password),
    case do (qlc:q ([X#users.username || X <- mnesia:table(users), check (X#users.username, X#users.email_address, Username), X#users.password == PasswordDigest])) of
        fail ->
            not_valid;
        Results ->        
            if 
                length (Results) == 1 ->
                    {valid, hd(Results)};
                true ->
                    not_valid
            end
    end.

get_gibes (Username) ->
    do (qlc:sort (qlc:q ([{Gibe#gibes.date, Gibe#gibes.gibe} || Gibe <- mnesia:table (gibes), string:equal(Gibe#gibes.username, Username)]))).                         

get_all_gibes (Username) ->
    QH1 = qlc:q ([{Gibe#gibes.username, Gibe#gibes.date, Gibe#gibes.gibe} || Gibe <- mnesia:table (gibes)]), 
    QH2 = qlc:q ([hd(Following#following.followee) || Following <- mnesia:table (following), string:equal(Following#following.username, Username)]),
    do (qlc:sort (qlc:q ([{U, D, G} || {U, D, G} <- QH1,  Followee <- QH2, ((Followee=:=U) or (U == Username))]))). 

%%% Checks the database to see if a username is already registered
is_username_used (Username) ->    
    case do (qlc:q ([X#users.username || X <- mnesia:table(users), string:equal(X#users.username, Username)])) of
        aborted ->
            false;
        Results ->        
            if 
                length (Results) == 1 ->
                    false;
                true ->
                    true
            end
    end.

%%% Run Query Q
do (Q) ->
    F = fun() -> qlc:e(Q) end,
    case mnesia:transaction (F) of
        {atomic, Val} ->
            Val;
        {aborted, Reason} ->
            io:format ("Query: ~s aborted.~nReason: ~s~n", [Q, Reason]),
            aborted    
    end.
                
write (Row) ->
    F = fun() ->
                mnesia:write (Row)
        end,
    mnesia:transaction (F).
    
delete (Table, Key) ->
    F = fun() ->
                mnesia:delete ({Table, Key})
        end,
    mnesia:transaction (F).
