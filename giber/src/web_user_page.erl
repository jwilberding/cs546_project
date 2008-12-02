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

    Username = wf:q (user),

    Template = #template {file="main_template", title="Edit Recipe",
                          section1 = #panel { style="margin: 50px;", 
                                              body=[
                                                    #file { file=Header },                         
                                                    User ++ " Gibes:",
                                                    #br{},
                                                    #button { id=follow, text="Follow", postback={follow, Username} },
                                                    #br{},
                                                    #flash { id=gibes },
                                                    #panel { id=test }
                                                   ]}},

    update_gibes(Username),
    
    wf:render(Template).

event ({follow, User}) ->
    db_backend:add_followee (wf:user(), User);   

event (_) ->
    ok.

update_gibes (User) ->
    Gibes = db_backend:get_all_gibes (User),
    lists:map (fun ({Username, Date, Gibe}) -> wf:insert_top (gibes, create_gibe_element(Gibe)) end, Gibes).
    
create_gibe_element (Gibe) ->
    FlashID = wf:temp_id(),
    InnerPanel = #panel { actions=#effect_blinddown 
                          { target=FlashID, duration=0.4 }, 
                          body=[
                                #panel { class=flash_content, body=#label{ text=Gibe }}]},
    [#panel { id=FlashID, style="display: none;", body=InnerPanel }].
