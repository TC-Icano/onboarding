-module(staff_roles_app).
-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    io:format("Starting Cowboy API...~n"),
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/roles", role_handler, []},
            {"/roles/:mrn", role_handler, []} %% Define route with mrn parameter
        ]}
    ]),
    {ok, _} = cowboy:start_clear(http_listener, [{port, 8080}], #{env => #{dispatch => Dispatch}}),
    io:format("Cowboy API started on port 8080~n"),
    {ok, self()}.

stop(_State) ->
    ok.
