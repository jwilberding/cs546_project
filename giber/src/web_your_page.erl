-module (web_your_page).
-include ("wf.inc").
-export ([main/0, event/1]).

main () ->    
    User = wf:user(),
    case User of        
        undefined ->
            Header = "new_user_header",
            wf:redirect ("register");
        _ ->
            Header = "user_header",
            ok
    end, 

    Template = #template {file="main_template", title="Your Page",
                          section1 = #panel { style="margin: 50px;", 
                                              body=[
                                                    #file { file=Header }, 
                                                    #textarea { id=input },
                                                    #button { id=add, text="Post", postback={add, User} },
                                                    #br{},
                                                    "Gibes:",                                                    
                                                    #br{},
                                                    #flash { id=gibes },
                                                   ]}},

    wf:wire(add, input, #validate { attach_to=input, validators=[#custom { text="Too long. Max=140 chars.", function=(fun (X, Y) -> check_length (X, Y) end) }] }),
    wf:wire(add, input, #validate { attach_to=input, validators=[#min_length { text="Add some text, doofus...", length=1 }] }),

    gibe_element:update_gibes(User),
    
    wf:render(Template).

event ({add, User}) ->
    db_backend:add_gibe (User, wf:q(input)),
    {{Y, M, D}, {Hour, Min, Sec}} = erlang:local_time(),
    Date = io_lib:format("~w~s~w~s~w~s~w~s~w~s~w", [M, "-", D, "-", Y, " at ", Hour, ":", Min, ":", Sec]),
    wf:insert_top (gibes, gibe_element:create_gibe_element (User,Date, wf:q(input)));

event (_) ->
    ok.

check_length (_, _) ->
    Length = length (hd(wf:q(input))),
    if 
        Length > 140 ->
            false;
        true ->
            true
    end.
