-module (web_user_page).
-include ("wf.inc").
-export ([main/0, event/1]).

main () ->    
    User = wf:user(),

    case User of        
        undefined ->
            Header = "new_user_header";
        _ ->
            Header = "user_header",
            ok
    end, 

    Username = hd(wf:q (user)),

    Template = #template {file="main_template", title="User Page",
                          section1 = #panel { style="margin: 50px;", 
                                              body=[
                                                    #file { file=Header },
                                                    #button { id=follow, text="Follow", postback={follow, Username, User} },
                                                    #flash { id=flash },
                                                    #br{},
                                                    Username ++ " gibes:",
                                                    #br{},
                                                    #panel { id=gibes },       
                                                   ]}},

    gibe_element:update_gibes(Username),
    
    wf:render(Template).

event ({follow, _Username, undefined}) ->     
    wf:flash ("Sorry, you aren't signed in.");
event ({follow, Username, User}) ->     
    db_backend:add_followee (User, Username);   

event (_) ->
    ok.
