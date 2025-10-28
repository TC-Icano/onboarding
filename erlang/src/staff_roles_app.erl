-module(staff_roles_app).
-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    io:format("Starting Staff roles API...~n"),
    
    %% Start the supervisor first
    case staff_roles_sup:start_link() of
        {ok, Pid} ->
            io:format("Supervisor started successfully~n"),
            
            %% Start the HTTP server
            Dispatch = cowboy_router:compile([
                {'_', [
                    {"/roles", role_handler, []},
                    {"/roles/:mrn", role_handler, []} %% Define route with mrn parameter
                ]}
            ]),
            {ok, _} = cowboy:start_clear(http_listener, [{port, 8080}], 
                                       #{env => #{dispatch => Dispatch}}),
            io:format("Staff roles API started on port 8080~n"),
            {ok, Pid};
        Error ->
            io:format("Failed to start supervisor: ~p~n", [Error]),
            Error
    end.

stop(_State) ->
    ok.
