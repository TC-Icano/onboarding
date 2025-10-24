-module(role_handler).
-behaviour(cowboy_handler).

%% Include record definitions
-include("../../include/records.hrl").

-export([init/2]).

%% Private helper functions
-export([send_json_response/3, send_json_response/4, send_error_response/3, send_error_response/4]).

%% init/2 is called by cowboy for this simple handler
init(Req0, _Opts) ->
    Method = cowboy_req:method(Req0),
    case Method of
        <<"GET">> ->
            %% Check for 'mrn' parameter
            case cowboy_req:binding(mrn, Req0) of
                undefined -> handle_get(Req0);
                Mrn -> handle_get_by_mrn(Req0, Mrn)
            end;
        <<"POST">> -> handle_post(Req0);

        <<"PUT">> ->
            case cowboy_req:binding(mrn, Req0) of
                undefined ->
                    {ok, Req} = send_error_response(Req0, 400, <<"Bad Request: 'mrn' parameter required">>),
                    {ok, Req, state};
                Mrn -> handle_put(Req0, Mrn)
            end;

        <<"DELETE">> ->
            case cowboy_req:binding(mrn, Req0) of
                undefined ->
                    {ok, Req} = send_error_response(Req0, 400, <<"Bad Request: 'mrn' parameter required">>),
                    {ok, Req, state};
                Mrn -> handle_delete(Req0, Mrn)
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

    %% Send response with all roles (get_all_roles always returns a list, even empty on error)
    {ok, Req} = send_json_response(Req0, 200, <<"Roles retrieved successfully">>, RolesJsonTerms),
    {ok, Req, state}.

%% Handle GET request with mrn parameter
handle_get_by_mrn(Req0, Mrn) ->
    %% Get role by mrn from service
    case role_service:get_role_by_mrn(Mrn) of
        {error, role_not_found} ->
            {ok, Req} = send_error_response(Req0, 404, <<"Role not found">>),
            {ok, Req, state};
        {error, Reason} ->
            {ok, Req} = send_error_response(Req0, 500, <<"Internal server error">>, Reason),
            {ok, Req, state};
        RoleJsonTerm ->
            {ok, Req} = send_json_response(Req0, 200, <<"Role retrieved successfully">>, RoleJsonTerm),
            {ok, Req, state}
    end.

%% POST: receives JSON body, builds records, replies
handle_post(Req0) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),

    %% Decode JSON body
    JsonTerm = jsx:decode(Body, [{labels, atom}]),

    %% Invoke create_role in role_service and handle result
    case role_service:create_role(JsonTerm) of
        {error, Reason} ->
            %% Handle error case
            {ok, Req} = send_error_response(Req1, 500, <<"Failed to create role">>, Reason),
            {ok, Req, state};
        RoleJsonTerm ->
            %% Success case - role was created and returned as JSON
            {ok, Req} = send_json_response(Req1, 201, <<"Item created successfully">>, RoleJsonTerm),
            {ok, Req, state}
    end.

%% PUT: receives JSON body, builds records, replies
handle_put(Req0, Mrn) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),

    %% Decode JSON body
    JsonTerm = jsx:decode(Body, [{labels, atom}]),

    %% Invoke update_role in role_service
    RoleJsonTerm = role_service:update_role(Mrn, JsonTerm),
    
    {ok, Req} = send_json_response(Req1, 200, <<"Item updated successfully">>, RoleJsonTerm),
    {ok, Req, state}.

%% Handle DELETE request with mrn parameter
handle_delete(Req0, Mrn) ->
    %% Invoke delete_role in role_service, it returns ok atom
    ok = role_service:delete_role(Mrn),

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
    {ok, cowboy_req:reply(StatusCode, Headers, JsonBinary, Req)}.

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
    {ok, cowboy_req:reply(StatusCode, Headers, JsonBinary, Req)}.
