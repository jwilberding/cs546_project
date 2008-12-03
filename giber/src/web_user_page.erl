-module (web_user_page).
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

    Username = hd(wf:q (username)),

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
                                                    #panel { id=test }
                                                   ]}},

    update_gibes(Username),
    
    wf:render(Template).

event ({follow, User, _}) ->     
    wf:flash ("Sorry, you aren't signed in.");
event ({follow, User}) ->     
    db_backend:add_followee (wf:user(), User);   

event (_) ->
    ok.

update_gibes (User) ->
    Gibes = db_backend:get_gibes (User),
    lists:map (fun ({_Key, Date, Gibe}) -> wf:insert_top (gibes, create_gibe_element(User, Date, Gibe)) end, Gibes).
    
create_gibe_element (Username, Date, Gibe) ->
    FlashID = wf:temp_id(),
    InnerPanel = #panel { class=flash, actions=#effect_blinddown 
                          { target=FlashID, duration=0.4 }, 
                          body=[
                                #panel { class=flash_content, body=[ Gibe, #br{}, "from: ", Username, " on " ]}]},
    [#panel { id=FlashID, style="display: none;", body=InnerPanel }].
