-module(role_service).

%% Include record definitions
-include("../../include/records.hrl").

%% Export functions
-export([
    get_all_roles/0,
    get_role_by_mrn/1,
    create_role/1,
    update_role/2,
    delete_role/1
]).

%% Get all roles from Redis repository
get_all_roles() ->
    case role_repository:get_all_roles() of
        {ok, Roles} ->
            %% Convert roles to JSON and return
            [json_utils:role_to_json(Role) || Role <- Roles];
        _ ->
            %% Return empty list or handle error as needed
            %% You might want to log this error
            []
    end.

%% Get role by mrn from Redis repository
get_role_by_mrn(Mrn) ->
    case role_repository:get_role_by_mrn(Mrn) of
        {ok, Role} ->
            %% Convert role to JSON and return
            json_utils:role_to_json(Role);
        {error, role_not_found} ->
            %% Return not found error
            {error, role_not_found};
        {error, Reason} ->
            %% Return error information
            {error, Reason}
    end.

%% Post: creates a new role
create_role(JsonTerm) ->
    %% Convert JSON to role record using json_utils
    RoleRec = json_utils:json_to_role(JsonTerm),

    %% Insert role into Redis repository
    case role_repository:insert_role(RoleRec) of
        {ok, InsertedRole} ->
            %% Return the inserted role as JSON
            json_utils:role_to_json(InsertedRole);
        {error, Reason} ->
            %% Return error information (you might want to handle this differently)
            {error, Reason}
    end.

%% Put: updates an existing role
update_role(Mrn, JsonTerm) ->
    %% Convert JSON to role record using json_utils
    RoleRec = json_utils:json_to_role(JsonTerm),

    %% Update role in Redis repository
    case role_repository:update_role(Mrn, RoleRec) of
        {ok, UpdatedRole} ->
            %% Return the updated role as JSON
            json_utils:role_to_json(UpdatedRole);
        {error, role_not_found} ->
            %% Return not found error
            {error, role_not_found};
        {error, Reason} ->
            %% Return error information
            {error, Reason}
    end.

%% Delete: deletes a role by mrn
delete_role(Mrn) ->
    %% Delete role from Redis repository
    case role_repository:delete_role(Mrn) of
        {ok, deleted} ->
            %% Return success confirmation
            {ok, deleted};
        {error, role_not_found} ->
            %% Return not found error
            {error, role_not_found};
        {error, Reason} ->
            %% Return error information
            {error, Reason}
    end.