-module(start_app).
-export([start/0]).

start() ->
    staff_roles_app:start(normal, []).
