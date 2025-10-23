-module(role_handler).
-behaviour(cowboy_handler).

%% Include record definitions
-include("../include/records.hrl").

-export([init/2]).

%% Private helper functions
-export([send_json_response/3, send_json_response/4, send_error_response/3, send_error_response/4]).

%% init/2 is called by cowboy for this simple handler
init(Req0, _Opts) ->
    Method = cowboy_req:method(Req0),
    case Method of
        <<"GET">> ->
            %% Check for 'id' parameter
            case cowboy_req:binding(id, Req0) of
                undefined -> handle_get(Req0);
                Id -> handle_get_by_id(Req0, Id)
            end;
        <<"POST">> -> handle_post(Req0);

        <<"PUT">> ->
            case cowboy_req:binding(id, Req0) of
                undefined ->
                    {ok, Req} = send_error_response(Req0, 400, <<"Bad Request: 'id' parameter required">>),
                    {ok, Req, state};
                Id -> handle_put(Req0, Id)
            end;

        <<"DELETE">> ->
            case cowboy_req:binding(id, Req0) of
                undefined ->
                    {ok, Req} = send_error_response(Req0, 400, <<"Bad Request: 'id' parameter required">>),
                    {ok, Req, state};
                Id -> handle_delete(Req0, Id)
            end;

        %% return 400 code if other methods
        _Other ->
            {ok, Req} = send_error_response(Req0, 400, <<"Bad Request">>),
            {ok, Req, state}
    end.

%% Handle GET request
handle_get(Req0) ->
    %% Get all roles from service
    RolesJsonTerms = role_service:get_all_roles(),

    %% Send response with all roles
    {ok, Req} = send_json_response(Req0, 200, <<"Roles retrieved successfully">>, RolesJsonTerms),
    {ok, Req, state}.

%% Handle GET request with id parameter
handle_get_by_id(Req0, Id) ->
    %% Get role by id from service
    RoleJsonTerm = role_service:get_role_by_id(Id),

    {ok, Req} = send_json_response(Req0, 200, <<"Role retrieved successfully">>, RoleJsonTerm),
    {ok, Req, state}.

%% POST: receives JSON body, builds records, replies
handle_post(Req0) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),

    %% Decode JSON body
    JsonTerm = jsx:decode(Body, [{labels, atom}]),

    %% Invoke create_role in role_service
    RoleJsonTerm = role_service:create_role(JsonTerm),

    {ok, Req} = send_json_response(Req1, 201, <<"Item created successfully">>, RoleJsonTerm),
    {ok, Req, state}.

%% PUT: receives JSON body, builds records, replies
handle_put(Req0, Id) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),

    %% Decode JSON body
    JsonTerm = jsx:decode(Body, [{labels, atom}]),

    %% Invoke update_role in role_service
    RoleJsonTerm = role_service:update_role(Id, JsonTerm),
    
    {ok, Req} = send_json_response(Req1, 200, <<"Item updated successfully">>, RoleJsonTerm),
    {ok, Req, state}.

%% Handle DELETE request with id parameter
handle_delete(Req0, Id) ->
    %% Invoke delete_role in role_service, it returns ok atom
    ok = role_service:delete_role(Id),

    %% Return confirmation JSON using helper function
    {ok, Req} = send_json_response(Req0, 200, <<"Item deleted successfully">>),
    {ok, Req, state}.

%% ============================================================================
%% Helper Functions
%% ============================================================================

%% Send a standardized JSON response with data
send_json_response(Req, StatusCode, Message, Data) ->
    ReplyTerm = json_utils:format_success_response(Message, Data),
    JsonBinary = jsx:encode(ReplyTerm),
    Headers = #{<<"content-type">> => <<"application/json">>},
    cowboy_req:reply(StatusCode, Headers, JsonBinary, Req).

%% Send a standardized JSON response with just a message (no data)
send_json_response(Req, StatusCode, Message) ->
    send_json_response(Req, StatusCode, Message, null).

%% Send a standardized error response
send_error_response(Req, StatusCode, Message) ->
    send_error_response(Req, StatusCode, Message, undefined).

send_error_response(Req, StatusCode, Message, Details) ->
    ReplyTerm = json_utils:format_error_response(StatusCode, Message, Details),
    JsonBinary = jsx:encode(ReplyTerm),
    Headers = #{<<"content-type">> => <<"application/json">>},
    cowboy_req:reply(StatusCode, Headers, JsonBinary, Req).
