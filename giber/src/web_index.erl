-module (web_index).
-include ("wf.inc").
-export ([main/0, event/1]).

main () ->    
    case wf:user() of
        undefined ->
            Header = "new_user_header";
        _ ->
            Header = "user_header"
    end,

    Template = #template {file="post_template", title="Giber",
                          section1 = #panel { style="margin: 50px;", 
                                             body=[
                                                   #file { file=Header },
                                                   #br{}, #br{},
                                                   "<input type=\"text\" name=\"name\">"
                                                  ]}},
    
    wf:render (Template).

event (_) -> 
    ok.
