%%%-------------------------------------------------------------------
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 2 2018 19:39
%%%-------------------------------------------------------------------
-module(fac1).

-export([main/0]).

main() ->
  I = 25,
  F = fac(I),
  io:format("factorial ~w = ~w~n",[I,F]),
  init:stop().

fac(0) -> 1;
fac(N) -> N * fac(N-1).