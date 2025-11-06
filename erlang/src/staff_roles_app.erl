-module(staff_roles_app).
-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    
    %% Start the supervisor first
    case staff_roles_sup:start_link() of
        {ok, Pid} ->
            
            %% Start the HTTP server
            Dispatch = cowboy_router:compile([
                {'_', [
                    % {"/roles", role_handler, []},
                    {"/roles/[:mrn]", role_handler, []} %% Define route with mrn parameter
                ]}
            ]),
            {ok, _} = cowboy:start_clear(http_listener, [{port, 8080}], 
                                       #{env => #{dispatch => Dispatch}}),
            {ok, Pid};
        Error ->
            Error
    end.

stop(_State) ->
    ok.
