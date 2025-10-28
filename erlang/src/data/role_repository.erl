-module(role_repository).

%% Include record definitions
-include("../../include/records.hrl").

%% Export functions
-export([
    insert_role/1,
    get_all_roles/0,
    get_role_by_mrn/1,
    update_role/2,
    delete_role/1
]).

%% Helper function to execute Redis commands through the connection GenServer
execute_redis_command(Command) ->
    redis_connection:execute(Command).

%% Insert a role into Redis
insert_role(Role) when is_record(Role, role) ->
    %% Generate a unique key for the role (using MRN as identifier)
    Key = generate_role_key(Role#role.data#data.mrn),
    
    %% Convert role to JSON for storage
    RoleJson = json_utils:role_to_json(Role),
    JsonBinary = jsx:encode(RoleJson),
    
    %% Store in Redis using SET command
    case execute_redis_command(["SET", Key, JsonBinary]) of
        {ok, <<"OK">>} ->
            %% Also add to a set for listing all roles
            case execute_redis_command(["SADD", "roles:all", Key]) of
                {ok, _} ->
                    {ok, Role};
                {error, Reason} ->
                    {error, {redis_error, Reason}}
            end;
        {error, Reason} ->
            {error, {redis_error, Reason}}
    end;
insert_role(_) ->
    {error, invalid_role_record}.

%% Get all roles from Redis
get_all_roles() ->
    case execute_redis_command(["SMEMBERS", "roles:all"]) of
        {ok, RoleKeys} ->
            %% Get all role data using the keys
            case get_roles_by_keys(RoleKeys) of
                {ok, Roles} ->
                    {ok, Roles};
                {error, Reason} ->
                    {error, {fetch_error, Reason}}
            end;
        {error, Reason} ->
            {error, {redis_error, Reason}}
    end.

%% Get a role by MRN
get_role_by_mrn(Mrn) when is_binary(Mrn) ->
    %% Generate the key for the MRN
    Key = generate_role_key(Mrn),
    
    case execute_redis_command(["GET", Key]) of
        {ok, undefined} ->
            {error, role_not_found};
        {ok, null} ->
            {error, role_not_found};
        {ok, JsonBinary} when is_binary(JsonBinary) ->
            JsonTerm = jsx:decode(JsonBinary, [{labels, atom}]),
            Role = json_utils:json_to_role(JsonTerm),
            {ok, Role};
        {error, Reason} ->
            {error, {redis_error, Reason}}
    end;
get_role_by_mrn(_) ->
    {error, invalid_mrn}.

%% Update an existing role by MRN
update_role(Mrn, UpdatedRole) when is_binary(Mrn), is_record(UpdatedRole, role) ->
    %% Generate the key for the MRN
    Key = generate_role_key(Mrn),
    
    case execute_redis_command(["EXISTS", Key]) of
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
            case execute_redis_command(["SET", Key, JsonBinary]) of
                {ok, <<"OK">>} ->
                    %% Ensure it's in the roles set (in case it wasn't)
                    case execute_redis_command(["SADD", "roles:all", Key]) of
                        {ok, _} ->
                            {ok, RoleWithCorrectMrn};
                        {error, Reason} ->
                            {error, {redis_error, Reason}}
                    end;
                {error, Reason} ->
                    {error, {redis_error, Reason}}
            end;
        {error, Reason} ->
            {error, {redis_error, Reason}}
    end;
update_role(_, _) ->
    {error, invalid_parameters}.

%% Delete a role by MRN
delete_role(Mrn) when is_binary(Mrn) ->
    %% Generate the key for the MRN
    Key = generate_role_key(Mrn),
    
    case execute_redis_command(["EXISTS", Key]) of
        {ok, <<"0">>} ->
            %% Role doesn't exist, cannot delete
            {error, role_not_found};
        {ok, <<"1">>} ->
            %% Role exists, proceed with deletion
            case execute_redis_command(["DEL", Key]) of
                {ok, <<"1">>} ->
                    %% Successfully deleted, also remove from the roles set
                    case execute_redis_command(["SREM", "roles:all", Key]) of
                        {ok, _} ->
                            {ok, deleted};
                        {error, Reason} ->
                            {error, {redis_error, Reason}}
                    end;
                {ok, <<"0">>} ->
                    {error, role_not_found};
                {error, Reason} ->
                    {error, {redis_error, Reason}}
            end;
        {error, Reason} ->
            {error, {redis_error, Reason}}
    end;
%% Handle invalid MRN parameter using pattern matching
delete_role(_) ->
    {error, invalid_mrn}.

%% Helper function to fetch multiple roles by their keys
get_roles_by_keys([]) ->
    {ok, []};
get_roles_by_keys(RoleKeys) ->
    %% Use MGET to fetch multiple values at once
    case execute_redis_command(["MGET" | RoleKeys]) of
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
