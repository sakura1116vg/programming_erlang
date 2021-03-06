%%%-------------------------------------------------------------------
%%% @author sakura1116
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%% 名前は同じだけどアリティが異なる関数
%%%
%%% @end
%%% Created : 12. 2 2018 11:02
%%%-------------------------------------------------------------------
-module(lib_misc).
-author("sakura1116").

%%-export([sum/1, sum/2, for/3, qsort/1, pythang/1, perms/1, odds_and_evens/1, odds_and_evens_acc/1, odds_and_evens_acc/3, sqrt/1]).
-compile(export_all).

sum(L) ->
  sum(L,0).

sum([], N) ->
  N;

sum([H|T], N) ->
  sum(T, H+N).

for(Max, Max, F) ->
  [F(Max)];

for(I, Max, F) ->
  [F(I)| for(I + 1, Max, F)].

%% クイックソート(実際のプログライミングでは++の使い方は【よくない】とされているが、説明をわかりやすくする為に記述)
qsort([]) ->
  [];
qsort([Pivot|T]) ->
  qsort([X || X <- T, X < Pivot])
  ++ [Pivot] ++
    qsort([X || X <- T, X >= Pivot]).


%% ピタゴラス数 = A*A + B*B = C*C
pythang(N) ->
  [
    {A,B,C} ||
    A <- lists:seq(1,N),
    B <- lists:seq(1,N),
    C <- lists:seq(1,N),
    A+B+C =< N,
    A*A+B*B =:= C*C
  ].

%% アナグラム
%% USAGE
%% lib_misc:perms("123").
perms([]) ->
  [[]];
perms(L) ->
  [ [H|T] || H <- L, T <- perms(L --[H]) ].


%% アキュムレータ
%% 1つの関数で2つのリストを得るにはどうすればよいか

%% このコードで問題なのは、リストを"2回"も辿っている点です
odds_and_evens(L) ->
  Odds  = [X || X <- L, (X rem 2) =:= 1],
  Evens = [X || X <- L, (X rem 2) =:= 0],
  {Odds, Evens}.


%% リストを2回辿らないようにするには、次のように書き換えればよい
%% これでリストをたどるのは1回だけになり、奇数の引数と偶数の引数をそれぞれ対応する出力リスト(アキュムレータ)に追加していくことができる
%% [H||filter(H)]方式と比較してアキュムレータを使ったほうが空間効率が良い。
odds_and_evens_acc(L) ->
  odds_and_evens_acc(L, [], []).

odds_and_evens_acc([H|T], Odds, Evens) ->
  case (H rem 2) of
    1 -> odds_and_evens_acc(T, [H|Odds], Evens);
    0 -> odds_and_evens_acc(T, Odds, [H|Evens])
  end;

odds_and_evens_acc([], Odds, Evens) ->
  % {Odds, Evens}.
  {lists:reverse(Odds), lists:reverse(Evens)}.

%% エラーメッセージ
sqrt(X) when X < 0 ->
  erlang:error({squareRootNegativeArgument, X});

sqrt(X) ->
  math:sqrt(X).


%% タイムアウトだけを指定した受信
%% この関数は現在のプロセスをTミリ秒間中断する
sleep(T) ->
  receive
    after T ->
    true
  end.

%% タイムアウト値が0の受信(P119)
%% タイムアウト値に0を指定するとタイムアウト説の内容が即座に実行されるが、その前に、システムはメールボックスの内容に対してパターン照合を試みる
%% この機能を使えば、プロセスのメールボックスのメッセージを全て吐き出して空にするflush_buffer関数を定義できる
flush_buffer() ->
  receive
    _Any ->
      flush_buffer()
  after 0 ->
    true
  end.

%% タイムアウト値に0を指定することによって、次のように一種の"優先順位付受信"を実現できる

priority_receive() ->
  receive
    {alarm, X} ->
      {alarm, X}
  after 0 ->
    receive
      Any ->
        Any
    end
  end.


%% プロセスは終了シグナルを補足するように設定することもできる。そのように設定したプロセスはシステムプロセスと呼ばれす(第9章 P127)
on_exit(Pid, Fun) ->
  spawn(fun() ->
    process_flag(trap_exit, true),
    link(Pid),
    receive
      {'EXIT', Pid, Why} ->
        Fun(Why)
    end
  end).

%% F = fun() -> receive X -> list_to_atom(X) end end.
%% Pid = spawn(F).
%% lib_misc:on_exit(Pid, fun(Why) -> io:format("~p died whith:~p~n", [Pid, Why]) end).


%% キープアライブプロセス 常に生きている登録済のプロセスで、このプロセスは何らかの要因で死んでも即座に再起動する。

keep_alive(Name, Fun) ->
  register(Name, Pid = spawn(Fun)),
  on_exit(Pid, fun(_Why) -> keep_alive(Name, Fun) end).


consult(File) ->
  case file:open(File, read) of
    {ok, S} ->
      Val = consult1(S),
      file:close(S),
      {ok, Val};
    {error, Why} ->
      {error, Why}
  end.

consult1(S) ->
  case io:read(S, '') of
    {ok, Term} -> [Term|consult1(S)];
    eof -> [];
    Error -> Error
  end.
