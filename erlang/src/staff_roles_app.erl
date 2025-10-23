-module(staff_roles_app).
-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    io:format("Starting Cowboy API...~n"),
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/hello", hello_handler, []},
            {"/hola", hello_handler, []},
            {"/roles", role_handler, []},
            {"/roles/:id", role_handler, []}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(http_listener, [{port, 8080}], #{env => #{dispatch => Dispatch}}),
    io:format("Cowboy API started on port 8080~n"),
    {ok, self()}.

stop(_State) ->
    ok.
