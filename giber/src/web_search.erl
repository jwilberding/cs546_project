-module (web_search).
-include ("wf.inc").
-export ([main/0, event/1]).

main () ->    
    Terms = hd(wf:q (name)),
    Results = get_results (Terms),

    Body = #body { body=#panel { style="margin: 50px;", 
                                 body=["Results:",
                                       #br{}]
                                       ++ Results ++
                                       [#flash { id=flash },
                                       #panel { id=test }
                                      ]}},
    wf:render(Body).

event (_) -> 
    ok.

get_results (Terms) ->
    Users = db_backend:find_users (Terms),
    [#link {text=User, url="user_page?user="++User} || User <- Users].
