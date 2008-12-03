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
                                                    User ++ " Gibes:",                                                    
                                                    #br{},
                                                    #flash { id=gibes },
                                                    #panel { id=test }
                                                   ]}},

    update_gibes(User),
    
    wf:render(Template).

event ({add, User}) ->
    db_backend:add_gibe (User, wf:q(input)),
    wf:insert_top (gibes, create_gibe_element (wf:q(input)));

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
