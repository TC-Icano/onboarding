-module(role_service).

%% Include record definitions
-include("../../include/records.hrl").

%% Export functions
-export([
    get_all_roles/0,
    get_role_by_id/1,
    create_role/1,
    update_role/2,
    delete_role/1
]).

%% Get all roles (hardcoded for now)
get_all_roles() ->
    %% Create sample role data
    Data1 = #data{
        first_name = <<"Adam">>,
        last_name = <<"Everyman">>,
        gender = <<"M">>,
        mrn = <<"99991946">>,
        organization = <<"GPXS87a6lEnkmzONMeR2qIVg">>
    },
    Role1 = #role{
        event_type = <<"Arrival">>,
        data = Data1
    },

    Data2 = #data{
        first_name = <<"Jane">>,
        last_name = <<"Smith">>,
        gender = <<"F">>,
        mrn = <<"99991947">>,
        organization = <<"GPXS87a6lEnkmzONMeR2qIVg">>
    },
    Role2 = #role{
        event_type = <<"Departure">>,
        data = Data2
    },

    Data3 = #data{
        first_name = <<"Bob">>,
        last_name = <<"Johnson">>,
        gender = <<"M">>,
        mrn = <<"99991948">>,
        organization = <<"GPXS87a6lEnkmzONMeR2qIVg">>
    },
    Role3 = #role{
        event_type = <<"Arrival">>,
        data = Data3
    },

    %% Convert roles to JSON and return
    Roles = [Role1, Role2, Role3],
    [json_utils:role_to_json(Role) || Role <- Roles].

%% Get role by id (hardcoded for now)
get_role_by_id(Id) ->
    %% Create sample role data
    Data = #data{
        first_name = <<"Adam">>,
        last_name = <<"Everyman">>,
        gender = <<"M">>,
        mrn = Id,
        organization = <<"GPXS87a6lEnkmzONMeR2qIVg">>
    },
    Role = #role{
        event_type = <<"Arrival">>,
        data = Data
    },

    %% Convert roles to JSON and return
    json_utils:role_to_json(Role).

%% Post: creates a new role
create_role(JsonTerm) ->
    %% Convert JSON to role record using json_utils
    RoleRec = json_utils:json_to_role(JsonTerm),

    %% Store in ETS (Erlang Term Storage)
    % ok = my_ets:insert(role_table, RoleRec),

    %% Return confirmation JSON using helper function
    json_utils:role_to_json(RoleRec).

%% Put: updates an existing role
update_role(Id, JsonTerm) ->
    %% Convert JSON to role record using json_utils
    RoleRec = json_utils:json_to_role(JsonTerm),

    %% Update the record with the ID (for demonstration, we'll update the first_name with the ID)
    UpdatedData = RoleRec#role.data#data{first_name = <<"Adam Updated">>},
    UpdatedRoleRec = RoleRec#role{data = UpdatedData},

    %% Store in ETS (Erlang Term Storage)
    % ok = my_ets:insert(role_table, UpdatedRoleRec),

    %% Return confirmation JSON using helper function
    json_utils:role_to_json(UpdatedRoleRec).

%% Delete: deletes a role by id
delete_role(Id) ->
    %% Simulate deletion from ETS
    % ok = my_ets:delete(role_table, Id),

    %% Return confirmation
    ok.