-module(redis_connection).

-behaviour(gen_server).

%% API
-export([
    start_link/0,
    get_connection/0,
    execute/1,
    execute/2,
    stop/0
]).

%% gen_server callbacks
-export([
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3
]).

%% Redis connection configuration (Docker setup)
-define(REDIS_HOST, "redis").  % Docker service name
-define(REDIS_PORT, 6379).
-define(REDIS_DATABASE, 0).
-define(SERVER, ?MODULE).
-define(RECONNECT_INTERVAL, 5000). % 5 seconds

-record(state, {
    connection = undefined,
    reconnect_timer = undefined
}).

%%%===================================================================
%%% API
%%%===================================================================

%% @doc Starts the redis connection gen_server
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%% @doc Get the current Redis connection
get_connection() ->
    gen_server:call(?SERVER, get_connection).

%% @doc Execute a Redis command
execute(Command) ->
    gen_server:call(?SERVER, {execute, Command}).

%% @doc Execute a Redis command with timeout
execute(Command, Timeout) ->
    gen_server:call(?SERVER, {execute, Command}, Timeout).

%% @doc Stop the gen_server
stop() ->
    gen_server:cast(?SERVER, stop).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%% @doc Initialize the gen_server
init([]) ->
    %% Start connection immediately
    error_logger:info_msg("Redis connection GenServer starting~n"),
    self() ! connect,
    {ok, #state{}}.

%% @doc Handle synchronous calls
handle_call(get_connection, _From, #state{connection = undefined} = State) ->
    {reply, {error, no_connection}, State};

handle_call(get_connection, _From, #state{connection = Conn} = State) ->
    {reply, {ok, Conn}, State};

handle_call({execute, Command}, _From, #state{connection = undefined} = State) ->
    {reply, {error, no_connection}, State};

handle_call({execute, Command}, _From, #state{connection = Conn} = State) ->
    Result = eredis:q(Conn, Command),
    {reply, Result, State};

handle_call(_Request, _From, State) ->
    {reply, {error, unknown_request}, State}.

%% @doc Handle asynchronous casts
handle_cast(stop, State) ->
    {stop, normal, State};

handle_cast(_Msg, State) ->
    {noreply, State}.

%% @doc Handle info messages
handle_info(connect, State) ->
    NewState = connect_to_redis(State),
    {noreply, NewState};

handle_info(reconnect, State) ->
    NewState = connect_to_redis(State),
    {noreply, NewState};

handle_info({'DOWN', _MonitorRef, process, Pid, _Reason}, 
            #state{connection = Pid} = State) ->
    %% Redis connection went down, schedule reconnection
    error_logger:warning_msg("Redis connection went down, scheduling reconnect~n"),
    Timer = erlang:send_after(?RECONNECT_INTERVAL, self(), reconnect),
    {noreply, State#state{connection = undefined, reconnect_timer = Timer}};

handle_info({'DOWN', _MonitorRef, process, _Pid, _Reason}, State) ->
    %% Some other process went down, ignore
    {noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.

%% @doc Handle termination
terminate(_Reason, #state{connection = Connection, reconnect_timer = Timer}) ->
    %% Cancel any pending reconnection timer
    case Timer of
        undefined -> ok;
        _ -> erlang:cancel_timer(Timer)
    end,
    %% Close Redis connection if it exists
    case Connection of
        undefined -> ok;
        Conn -> eredis:stop(Conn)
    end,
    ok.

%% @doc Handle code changes
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

%% @doc Attempt to connect to Redis
connect_to_redis(#state{reconnect_timer = Timer} = State) ->
    %% Cancel any existing reconnection timer
    case Timer of
        undefined -> ok;
        _ -> erlang:cancel_timer(Timer)
    end,
    
    case eredis:start_link(?REDIS_HOST, ?REDIS_PORT, ?REDIS_DATABASE) of
        {ok, Connection} ->
            %% Monitor the connection process so we know when it dies
            erlang:monitor(process, Connection),
            error_logger:info_msg("Redis connection established~n"),
            State#state{connection = Connection, reconnect_timer = undefined};
        {error, Reason} ->
            error_logger:error_msg("Failed to connect to Redis: ~p~n", [Reason]),
            %% Schedule a reconnection attempt
            NewTimer = erlang:send_after(?RECONNECT_INTERVAL, self(), reconnect),
            State#state{connection = undefined, reconnect_timer = NewTimer}
    end.