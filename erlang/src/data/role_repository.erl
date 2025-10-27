-module(role_repository).

%% Include record definitions
-include("../../include/records.hrl").

%% Export functions
-export([
    insert_role/1,
    get_all_roles/0,
    get_role_by_mrn/1,
    update_role/2,
    delete_role/1,
    connect/0,
    disconnect/1
]).

%% Redis connection configuration (Docker setup)
-define(REDIS_HOST, "redis").  % Docker service name
-define(REDIS_PORT, 6379).
-define(REDIS_DATABASE, 0).

%% Connect to Redis
connect() ->
    case eredis:start_link(?REDIS_HOST, ?REDIS_PORT, ?REDIS_DATABASE) of
        {ok, Client} -> 
            {ok, Client};
        {error, Reason} -> 
            {error, Reason}
    end.

%% Disconnect from Redis
disconnect(Client) ->
    eredis:stop(Client).

%% Insert a role into Redis (basic version without try-catch)
insert_role(Role) when is_record(Role, role) ->
    case connect() of
        {ok, Client} ->
            %% Generate a unique key for the role (using MRN as identifier)
            Key = generate_role_key(Role#role.data#data.mrn),
            
            %% Convert role to JSON for storage
            RoleJson = json_utils:role_to_json(Role),
            JsonBinary = jsx:encode(RoleJson),
            
            %% Store in Redis using SET command
            Result = case eredis:q(Client, ["SET", Key, JsonBinary]) of
                {ok, <<"OK">>} ->
                    %% Also add to a set for listing all roles
                    eredis:q(Client, ["SADD", "roles:all", Key]),
                    {ok, Role};
                {error, Reason} ->
                    {error, {redis_error, Reason}}
            end,
            
            %% Always disconnect
            disconnect(Client),
            Result;
        {error, Reason} ->
            {error, {connection_failed, Reason}}
    end;
insert_role(_) ->
    {error, invalid_role_record}.

%% Get all roles from Redis
get_all_roles() ->
    case connect() of
        {ok, Client} ->
            Result = case eredis:q(Client, ["SMEMBERS", "roles:all"]) of
                {ok, RoleKeys} ->
                    %% Get all role data using the keys
                    case get_roles_by_keys(Client, RoleKeys) of
                        {ok, Roles} ->
                            {ok, Roles};
                        {error, Reason} ->
                            {error, {fetch_error, Reason}}
                    end;
                {error, Reason} ->
                    {error, {redis_error, Reason}}
            end,
            
            %% Always disconnect
            disconnect(Client),
            Result;
        {error, Reason} ->
            {error, {connection_failed, Reason}}
    end.

%% Get a role by MRN
get_role_by_mrn(Mrn) when is_binary(Mrn) ->
    case connect() of
        {ok, Client} ->
            %% Generate the key for the MRN
            Key = generate_role_key(Mrn),
            
            Result = case eredis:q(Client, ["GET", Key]) of
                {ok, undefined} ->
                    {error, role_not_found};
                {ok, null} ->
                    {error, role_not_found};
                {ok, JsonBinary} when is_binary(JsonBinary) ->
                    try
                        JsonTerm = jsx:decode(JsonBinary, [{labels, atom}]),
                        Role = json_utils:json_to_role(JsonTerm),
                        {ok, Role}
                    catch
                        _:Error ->
                            {error, {parse_error, Error}}
                    end;
                {error, Reason} ->
                    {error, {redis_error, Reason}}
            end,
            
            %% Always disconnect
            disconnect(Client),
            Result;
        {error, Reason} ->
            {error, {connection_failed, Reason}}
    end;
get_role_by_mrn(_) ->
    {error, invalid_mrn}.

%% Update an existing role by MRN
update_role(Mrn, UpdatedRole) when is_binary(Mrn), is_record(UpdatedRole, role) ->
    case connect() of
        {ok, Client} ->
            %% Generate the key for the MRN
            Key = generate_role_key(Mrn),
            
            Result = case eredis:q(Client, ["EXISTS", Key]) of
                {ok, <<"0">>} ->
                    %% Role doesn't exist, cannot update
                    {error, role_not_found};
                {ok, <<"1">>} ->
                    %% Role exists, proceed with update
                    %% Ensure the MRN in the updated role matches the key
                    RoleWithCorrectMrn = UpdatedRole#role{
                        data = (UpdatedRole#role.data)#data{mrn = Mrn}
                    },
                    
                    %% Convert role to JSON for storage
                    RoleJson = json_utils:role_to_json(RoleWithCorrectMrn),
                    JsonBinary = jsx:encode(RoleJson),
                    
                    %% Update in Redis using SET command
                    case eredis:q(Client, ["SET", Key, JsonBinary]) of
                        {ok, <<"OK">>} ->
                            %% Ensure it's in the roles set (in case it wasn't)
                            eredis:q(Client, ["SADD", "roles:all", Key]),
                            {ok, RoleWithCorrectMrn};
                        {error, Reason} ->
                            {error, {redis_error, Reason}}
                    end;
                {error, Reason} ->
                    {error, {redis_error, Reason}}
            end,
            
            %% Always disconnect
            disconnect(Client),
            Result;
        {error, Reason} ->
            {error, {connection_failed, Reason}}
    end;
update_role(_, _) ->
    {error, invalid_parameters}.

%% Delete a role by MRN
delete_role(Mrn) when is_binary(Mrn) ->
    case connect() of
        {ok, Client} ->
            %% Generate the key for the MRN
            Key = generate_role_key(Mrn),
            
            Result = case eredis:q(Client, ["EXISTS", Key]) of
                {ok, <<"0">>} ->
                    %% Role doesn't exist, cannot delete
                    {error, role_not_found};
                {ok, <<"1">>} ->
                    %% Role exists, proceed with deletion
                    case eredis:q(Client, ["DEL", Key]) of
                        {ok, <<"1">>} ->
                            %% Successfully deleted, also remove from the roles set
                            eredis:q(Client, ["SREM", "roles:all", Key]),
                            {ok, deleted};
                        {ok, <<"0">>} ->
                            {error, role_not_found};
                        {error, Reason} ->
                            {error, {redis_error, Reason}}
                    end;
                {error, Reason} ->
                    {error, {redis_error, Reason}}
            end,
            
            %% Always disconnect
            disconnect(Client),
            Result;
        {error, Reason} ->
            {error, {connection_failed, Reason}}
    end;
%% Handle invalid MRN parameter using pattern matching
delete_role(_) ->
    {error, invalid_mrn}.

%% Helper function to fetch multiple roles by their keys
get_roles_by_keys(_Client, []) ->
    {ok, []};
get_roles_by_keys(Client, RoleKeys) ->
    %% Use MGET to fetch multiple values at once
    case eredis:q(Client, ["MGET" | RoleKeys]) of
        {ok, JsonValues} ->
            %% Convert JSON strings back to role records
            Roles = lists:filtermap(fun(JsonBinary) ->
                case JsonBinary of
                    undefined -> false;  % Key doesn't exist
                    null -> false;       % Redis null value
                    JsonData when is_binary(JsonData) ->
                        JsonTerm = jsx:decode(JsonData, [{labels, atom}]),
                        Role = json_utils:json_to_role(JsonTerm),
                        {true, Role};
                    _ -> false
                end
            end, JsonValues),
            {ok, Roles};
        {error, Reason} ->
            {error, {mget_error, Reason}}
    end.

%% Generate Redis key for a role
generate_role_key(Mrn) ->
    iolist_to_binary(["role:", Mrn]).
