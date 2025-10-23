-module(json_utils).

%% Exports
-export([
    role_to_json/1,
    json_to_role/1,
    format_error_response/2,
    format_error_response/3,
    format_success_response/2
]).

%% Include record definitions
-include("../../include/records.hrl").

%% Convert role record to JSON term
role_to_json(Role) ->
    [
        {event_type, Role#role.event_type},
        {data, [
            {first_name, Role#role.data#data.first_name},
            {last_name, Role#role.data#data.last_name},
            {gender, Role#role.data#data.gender},
            {mrn, Role#role.data#data.mrn},
            {organization, Role#role.data#data.organization}
        ]}
    ].

%% Convert JSON term to role record
json_to_role(JsonTerm) ->
    EventType = proplists:get_value(event_type, JsonTerm),
    DataProps = proplists:get_value(data, JsonTerm),
    
    Data = #data{
        first_name = proplists:get_value(first_name, DataProps),
        last_name = proplists:get_value(last_name, DataProps),
        gender = proplists:get_value(gender, DataProps),
        mrn = proplists:get_value(mrn, DataProps),
        organization = proplists:get_value(organization, DataProps)
    },
    
    #role{
        event_type = EventType,
        data = Data
    }.

%% Format error response using record
format_error_response(Code, Message) ->
    format_error_response(Code, Message, undefined).

format_error_response(Code, Message, Details) ->
    ErrorRecord = #api_error{
        error = true,
        code = Code,
        message = Message,
        details = Details
    },
    api_error_to_json(ErrorRecord).

%% Format success response using record
format_success_response(Message, Data) ->
    ResponseRecord = #api_response{
        success = true,
        message = Message,
        data = Data,
        timestamp = erlang:system_time(second)
    },
    api_response_to_json(ResponseRecord).

%% Convert API response record to JSON
api_response_to_json(Response) ->
    [
        {success, Response#api_response.success},
        {message, Response#api_response.message},
        {data, Response#api_response.data},
        {timestamp, Response#api_response.timestamp}
    ].

%% Convert API error record to JSON
api_error_to_json(Error) ->
    Base = [
        {error, Error#api_error.error},
        {code, Error#api_error.code},
        {message, Error#api_error.message}
    ],
    case Error#api_error.details of
        undefined -> Base;
        Details -> [{details, Details} | Base]
    end.