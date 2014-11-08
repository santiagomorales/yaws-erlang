-module(tablasETS).
%-export([start/0, crearETS/0]).
-export([start/0]).

procesar(Origen) ->
	case file:open(Origen, read) of
		{ok, Fd_origen} ->
			procesar_linea(Fd_origen),
			file:close(Fd_origen),
			{ok};
		{error, Motivo} ->
			{error, Motivo}
end.

procesar_linea(Fd_origen) ->
	case io:get_line(Fd_origen, '') of
		eof ->
			io:format("Done ~n");
		{error, Motivo} ->
			{error, Motivo};
		Linea ->
			Tokens = string:tokens(Linea, ","),
			io:format("~s", [Tokens]),
			procesar_linea(Fd_origen)
	end.


%crearETS() ->
%		receive
%		crear ->
%			ets:new(tablaETS, [set, named_table]),
%			procesar("mini.csv"),
%			io:format("TABLA ETS CREADA\n", [])
%		end.
 

start() ->
%	register(crearETS, spawn(tablasETS, crearETS, [])). 
	ets:new(tablaETS, [set, named_table]),
	procesar(mini.csv).	


