-module(hello_handler).
-behaviour(cowboy_handler).
-export([init/2]).

init(Request, State) ->
    ResponseHeaders = #{<<"content-type">> => <<"text/plain">>},
    Body = <<"This is a test from erlang project!!">>,
    {ok, Response} = cowboy_req:reply(
            200,
            ResponseHeaders,
            Body,
            Request
        ),
    {ok, Response, State}.
