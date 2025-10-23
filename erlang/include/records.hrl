%% ============================================================================
%% Staff Roles Application Records
%% ============================================================================

%% Staff member personal data
-record(data, {
    first_name :: binary(),           % Staff member's first name
    last_name :: binary(),            % Staff member's last name  
    gender :: binary(),               % Gender (M/F/Other)
    mrn :: binary(),                  % Medical Record Number or Staff ID
    organization :: binary()          % Organization identifier
}).

%% Role assignment record
-record(role, {
    event_type :: binary(),           % Type of event (Arrival, Departure, etc.)
    data :: #data{}                   % Staff member data
}).

%% API Response records
-record(api_response, {
    success :: boolean(),             % Success flag
    message :: binary(),              % Response message
    data :: term(),                   % Response data
    timestamp :: integer()            % Response timestamp
}).

-record(api_error, {
    error :: boolean(),               % Error flag
    code :: integer(),                % HTTP status code
    message :: binary(),              % Error message
    details :: term()                 % Additional error details
}).