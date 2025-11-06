-module(role_handler).
-behaviour(cowboy_rest).

%% Include record definitions
-include("../../include/records.hrl").

%% cowboy_rest callbacks
-export([
    init/2,
    allowed_methods/2,
    content_types_provided/2,
    content_types_accepted/2,
    delete_resource/2,
    post_is_create/2,
    create_path/2,
    from_json/2,
    to_json/2
]).

%% Initialize the REST handler
init(Req, Opts) ->
    {cowboy_rest, Req, Opts}.

%% Define which HTTP methods are allowed
allowed_methods(Req, State) ->
    {[<<"GET">>, <<"POST">>, <<"PUT">>, <<"DELETE">>], Req, State}.

%% Define content types this resource can provide (for GET requests)
content_types_provided(Req, State) ->
    {[{<<"application/json">>, to_json}], Req, State}.

%% Define content types this resource can accept (for POST/PUT requests)
content_types_accepted(Req, State) ->
    {[{<<"application/json">>, from_json}], Req, State}.

%% Indicate that POST requests create new resources
post_is_create(Req, State) ->
    {true, Req, State}.

%% Create path for POST requests (we'll return the created resource location)
create_path(Req, State) ->
    {<<"/roles">>, Req, State}.



%% Handle GET requests - provide JSON representation
to_json(Req, State) ->
    case cowboy_req:binding(mrn, Req) of
        undefined ->
            %% Get all roles
            RolesJsonTerms = role_service:get_all_roles(),
            case RolesJsonTerms of
                [] ->
                    Response = json_utils:format_error_response(404, <<"No roles found">>),
                    JsonBinary = jsx:encode(Response),
                    Req2 = cowboy_req:set_resp_body(JsonBinary, Req),
                    {JsonBinary, Req2, State};
                Roles when is_list(Roles) ->
                    Response = json_utils:format_success_response(<<"Roles retrieved successfully">>, Roles),
                    JsonBinary = jsx:encode(Response),
                    {JsonBinary, Req, State}
            end;
        Mrn ->
            %% Get role by MRN
            case role_service:get_role_by_mrn(Mrn) of
                {error, role_not_found} ->
                    Response = json_utils:format_error_response(404, <<"Role not found">>),
                    JsonBinary = jsx:encode(Response),
                    Req2 = cowboy_req:reply(404, #{<<"content-type">> => <<"application/json">>}, JsonBinary, Req),
                    {halt, Req2, State};
                {error, _} ->
                    Response = json_utils:format_error_response(500, <<"Internal server error">>),
                    JsonBinary = jsx:encode(Response),
                    Req2 = cowboy_req:reply(500, #{<<"content-type">> => <<"application/json">>}, JsonBinary, Req),
                    {halt, Req2, State};
                RoleJsonTerm ->
                    Response = json_utils:format_success_response(<<"Role retrieved successfully">>, RoleJsonTerm),
                    JsonBinary = jsx:encode(Response),
                    {JsonBinary, Req, State}
            end
    end.

%% Handle JSON input for both POST and PUT requests
%% cowboy_rest will call this for both POST and PUT based on the flow
from_json(Req, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req),
    JsonTerm = jsx:decode(Body, [{labels, atom}]),
    
    %% Check if this is a PUT request by looking for MRN binding
    case cowboy_req:binding(mrn, Req1) of
        undefined ->
            %% No MRN means this should be a POST (create) operation
            case role_service:create_role(JsonTerm) of
                {error, Reason} ->
                    Response = json_utils:format_error_response(500, <<"Failed to create role">>, Reason),
                    JsonBinary = jsx:encode(Response),
                    Req2 = cowboy_req:reply(500, #{<<"content-type">> => <<"application/json">>}, JsonBinary, Req1),
                    {halt, Req2, State};
                RoleJsonTerm ->
                    Response = json_utils:format_success_response(<<"Item created successfully">>, RoleJsonTerm),
                    JsonBinary = jsx:encode(Response),
                    Req2 = cowboy_req:set_resp_body(JsonBinary, Req1),
                    {true, Req2, State}
            end;
        Mrn ->
            %% MRN present means this is a PUT (update) operation
            case role_service:update_role(Mrn, JsonTerm) of
                {error, role_not_found} ->
                    Response = json_utils:format_error_response(404, <<"Role not found">>),
                    JsonBinary = jsx:encode(Response),
                    Req2 = cowboy_req:reply(404, #{<<"content-type">> => <<"application/json">>}, JsonBinary, Req1),
                    {halt, Req2, State};
                {error, Reason} ->
                    Response = json_utils:format_error_response(500, <<"Failed to update role">>, Reason),
                    JsonBinary = jsx:encode(Response),
                    Req2 = cowboy_req:reply(500, #{<<"content-type">> => <<"application/json">>}, JsonBinary, Req1),
                    {halt, Req2, State};
                RoleJsonTerm ->
                    Response = json_utils:format_success_response(<<"Item updated successfully">>, RoleJsonTerm),
                    JsonBinary = jsx:encode(Response),
                    Req2 = cowboy_req:set_resp_body(JsonBinary, Req1),
                    {true, Req2, State}
            end
    end.

%% Handle DELETE requests
delete_resource(Req, State) ->
    case cowboy_req:binding(mrn, Req) of
        undefined ->
            Response = json_utils:format_error_response(400, <<"Bad Request: 'mrn' parameter required">>),
            JsonBinary = jsx:encode(Response),
            Req2 = cowboy_req:reply(400, #{<<"content-type">> => <<"application/json">>}, JsonBinary, Req),
            {halt, Req2, State};
        Mrn ->
            case role_service:delete_role(Mrn) of
                {ok, deleted} ->
                    Response = json_utils:format_success_response(<<"Item deleted successfully">>, null),
                    JsonBinary = jsx:encode(Response),
                    Req2 = cowboy_req:set_resp_body(JsonBinary, Req),
                    {true, Req2, State};
                {error, role_not_found} ->
                    Response = json_utils:format_error_response(404, <<"Role not found">>),
                    JsonBinary = jsx:encode(Response),
                    Req2 = cowboy_req:reply(404, #{<<"content-type">> => <<"application/json">>}, JsonBinary, Req),
                    {halt, Req2, State};
                {error, Reason} ->
                    Response = json_utils:format_error_response(500, <<"Failed to delete role">>, Reason),
                    JsonBinary = jsx:encode(Response),
                    Req2 = cowboy_req:reply(500, #{<<"content-type">> => <<"application/json">>}, JsonBinary, Req),
                    {halt, Req2, State}
            end
    end.


