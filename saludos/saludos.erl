-module(saludos).
-export([start_hola/1, start_adios/0, hola/1, adios/0]).

adios() ->
	receive
		{hola, Hola_Node, Mensaje} ->
			io:format("He recibido ~p\n", [Mensaje]),
			Mensaje2 = "adiooooos",
			Hola_Node ! {adios, Mensaje2},
			adios()
	end.

hola(Adios_Node) ->
	Mensaje = "holaaa",
	{adios, Adios_Node} ! {hola, self(), Mensaje},
	receive
		{adios, Mensaje2} ->
			io:format("He recibido ~p\n", [Mensaje2])
	end.

start_adios() ->
	register(adios, spawn(saludos, adios, [])).

start_hola(Adios_Node) ->
	spawn(saludos, hola, [Adios_Node]).
