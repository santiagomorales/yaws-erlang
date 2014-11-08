-module(saludos_procesos).
-export([start/0, hola/0, adios/0]).


adios() ->
	receive
		{hola, Hola_pid, Mensaje} ->
			io:format("He recibido un ~p~n", [Mensaje]),
			Mensaje2 = "taluegooo",
			Hola_pid ! Mensaje2
	end.

hola() ->
	Mensaje = "holaaaaa",
	adios ! {hola, self(), Mensaje},
	receive
		Mensaje2 ->
			io:format("He recibido un ~p~n", [Mensaje2])
	end.

start() ->
	register(adios, spawn(saludos_procesos, adios, [])),
	spawn(saludos_procesos, hola, []).
