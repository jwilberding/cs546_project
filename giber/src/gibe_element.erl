-module (gibe_element).
-include ("wf.inc").
-export ([update_gibes/1, create_gibe_element/3]).

update_gibes (User) ->
    Gibes = db_backend:get_all_gibes (User),
    
    lists:foreach (fun ({_K, Username, {{Y, M, D}, {Hour, Min, Sec}}, Gibe}) -> 
                           Date = io_lib:format("~w~s~w~s~w~s~w~s~w~s~w", [M, "-", D, "-", Y, " at ", Hour, ":", Min, ":", Sec]),
                           wf:insert_top (gibes, create_gibe_element(Username, Date, Gibe)) end, Gibes).

create_gibe_element (Username, Date, Gibe) ->
    FlashID = wf:temp_id(),
    InnerPanel = #panel { class=flash, actions=#effect_blinddown 
                          { target=FlashID, duration=0.4 }, 
                          body=[
                                #panel { class=flash_content, body=[ Gibe, #br{}, "from: ", Username, " on ", Date ] }]},
    [#panel { id=FlashID, style="display: none;", body=InnerPanel }].
