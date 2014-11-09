-module(tablasETS).
%-export([start/0, crearETS/0]).
-export([start/0, procesar/0, procesar_linea/1]).
-record(address, {postalcode, placename, state, county, stateab, latitude, longitude}).

procesar() ->
	receive
		{Origen} ->
			case file:open(Origen, read) of
				{ok, Fd_origen} ->
					procesar_linea(Fd_origen),
					file:close(Fd_origen),
					{ok};
				{error, Motivo} ->
					{error, Motivo}
			end
	end.

procesar_linea(Fd_origen) ->
	case io:get_line(Fd_origen, '') of
		eof ->
			io:format("Done ~n");
		{error, Motivo} ->
			{error, Motivo};
		Linea ->
			[Postal, Place, State, StateAb, County, Latitude, Longitude, Rest] = string:tokens(Linea, ","),
			A = #address{postalcode = Postal, placename = Place, state = State, stateab = StateAb, county = County, latitude = Latitude, longitude = Longitude},
			ets:insert(tablaETS, A),
			procesar_linea(Fd_origen)
	end.

 
start() ->
	register(procesar, spawn(tablasETS, procesar, [])),
	ets:new(tablaETS, [set, named_table, public]),
	procesar ! {"mini.csv"}.

