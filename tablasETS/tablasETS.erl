-module(tablasETS).
-export([start/0, procesar/0, procesar_linea/1, buscar/0]).
-record(address, {postalcode, placename, state, county, stateab, latitude, longitude}).
-author('santi').

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
			io:format("ETS Table created ~n");
		{error, Motivo} ->
			{error, Motivo};
		Linea ->
			% erase the substring ",\n" at the end of the line. There's also some lines with 5/6 at the end, that's the reason of the regex. 
			Line = re:replace(Linea, ",(5|6)?\n", "", [global,{return,list}]),

			% some lines haven't the field "county" (and some haven't also the field "state",
			% so I have to check if the line has the substring ",," to know 
			% how do I have to insert the elements in the table (county = "" or county = County)

			case re:run(Line, ",,", [{capture, first, list}]) of
				{match, [",,"]} ->	% if it hasn't the field county
					%% find how many times is the substring ",," in the line
					case erlang:length(binary:split(binary:list_to_bin(Line), binary:list_to_bin(",,"), [global])) - 1  of
						1 -> % there's 6 fields in Line 
							[Postal, Place, State, StateAb, Latitude, Longitude] = string:tokens(Line, ","),
							ets:insert(tablaETS, #address{postalcode = Postal, placename = Place, state = State, stateab = StateAb, 
								county = "", latitude = Latitude, longitude = Longitude});
						_Else -> % there's 5 fields in Line
							[Postal, Place, StateAb, Latitude, Longitude] = string:tokens(Line, ","),
							ets:insert(tablaETS, #address{postalcode = Postal, placename = Place, state = "", stateab = StateAb, 
								county = "", latitude = Latitude, longitude = Longitude})
					end;
				_Else ->	% it has all the attributes, normal case
					[Postal, Place, State, StateAb, County, Latitude, Longitude] = string:tokens(Line, ","),
					ets:insert(tablaETS, #address{postalcode = Postal, placename = Place, state = State, stateab = StateAb, 
								county = County, latitude = Latitude, longitude = Longitude})
			end,
			procesar_linea(Fd_origen)
	end.

buscar() ->
	receive
		Postalcode ->
			Info = ets:lookup(tablaETS, Postalcode),
			io:format("~p~n", [Info]),
			buscar()
	end.
 
start() ->
	register(procesar, spawn(tablasETS, procesar, [])),
	register(buscar, spawn(tablasETS, buscar, [])),
	ets:new(tablaETS, [set, named_table, public, {keypos, #address.postalcode}]),
	procesar ! {"us_postal_codes.csv"}.

