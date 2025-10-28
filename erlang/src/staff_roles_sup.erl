%%%-------------------------------------------------------------------
%% @doc staff_roles top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(staff_roles_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    SupFlags = #{
        strategy => one_for_all,
        intensity => 5,  %% Allow 5 restarts
        period => 10     %% Within 10 seconds
    },
    ChildSpecs = [
        #{
            id => redis_connection,
            start => {redis_connection, start_link, []},
            restart => permanent,
            shutdown => 5000,
            type => worker,
            modules => [redis_connection]
        }
    ],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
