defmodule Protobufs do
	@moduledoc """
	  This module was created like an bridge for Protobuf application,
	  which created for possibility to work comfortable with Protocol buffers in Elixir taken from there
	  github.com/bitwalker/exprotobuf
	"""
	use Protobuf, from: Path.wildcard(Path.expand("./*.proto", __DIR__))
end

defmodule HttpServer.ProtobufApiHandler do
	@moduledoc """
	  HttpServer.ProtobufApiHandler module was made for handling requests for protocol buffers version of api.
	  The idea is that public functions in this module should have the common names defined for each possible types of requests 
	  and for every request envisaged particular function, which determines with help of pattern matching - one of the main beautiful things in Elixir.
	"""
	@headers %{
      "Access-Control-Allow-Methods" => "GET",
      "Access-Control-Allow-Headers" => "Origin, Content-Type, Accept, Authorization, Access-Control-Allow-Credentials",
      "Access-Control-Allow-Credentials" => "true"
	}

	@doc """
		handle_get_request/4 - function, which handle the get requests to the Protobuf version of API
		
		In some implementations of this functions some of arguments are ignored specially cuz of there is no need for them
		## Parameters

		    - first argument: String that consist of string beetween "/protobuf_api" and querystring in user request
		    - query: it's a map which represents the querystring of handling request in "key" => value form
		    - headers: it's a map which represents the headers of handling request in "key" => value form
		    - state: it's an argument which thrown, for needs of http server library and contains of map with to default keys: host and socket, where host - it's server ip and socket address 
			

	"""
	@doc """
		handle_get_request("/list", _query, headers, state) handles the GET "/list" request and send the list of available in API tournament-season pairs
	"""
	def handle_get_request("/list", _query, headers, state) do
		list = EtsTable.select_pairs_list
		response_list = Enum.map(list, fn(x)->
			{{tournament, season}} = x
			Protobufs.SeasonPair.new(%{tournament: tournament, season: season})
        end)
		msg = Protobufs.ListMsg.new(list: response_list)
		#origin header is needed for comfortable use of this api in front end 
        origin = case headers["origin"] do
			nil ->
				%{}
			_ ->
				%{"Access-Control-Allow-Origin" => headers["origin"]}
		end
		{200, Map.merge(origin, @headers), Base.encode16(Protobufs.ListMsg.encode(msg), case: :lower), state}
	end
	@doc """
		handle_get_request("/fetch_results", query, _headers, state) handles the GET "/fetch_results" request and send the match results for given using querystring tournament-season pair 
	"""
	def handle_get_request("/fetch_results", query, headers, state) do
		season = String.to_integer(query["season"])
		tournament = query["tournament"]
		dataset = EtsTable.select_by_season_and_tournament(season, tournament)
		sorted_dataset = Enum.sort(dataset, fn (x, y) -> 
			{ id, _home_team, _away_team, date, _tournament, _ftag, _fthg, _ftr, _htag, _hthg, _htr, _season} = x
			{ id2, _home_team, _away_team, date2, _tournament, _ftag, _fthg, _ftr, _htag, _hthg, _htr, _season} = y
			case Date.compare(date , date2) do
				:gt ->
					false
				:eq ->
					id < id2
			    _ ->
			    	true
			end
		end)
		response_list = Enum.map(sorted_dataset, fn({ id, home_team, away_team, date, tournament, ftag, fthg, ftr, htag, hthg, htr, season})->
            {year, month, day} = Date.to_erl(date)
            date = Integer.to_string(day)<>"/"<>Integer.to_string(month)<>"/"<>Integer.to_string(year)
            Protobufs.MatchResult.new(%{
                id: id,
                home_team: home_team,
                away_team: away_team,
                date: date,
                tournament: tournament,
                ftag: String.to_integer(ftag),
                fthg: String.to_integer(fthg),
                ftr: ftr,
                htag: String.to_integer(htag),
                hthg: String.to_integer(hthg),
                htr: htr,
                season: season
            })
        end)
		msg = case response_list do
			[] ->
				response = Protobufs.FetchResultsMsgError.new(reason: "There is no results for given tournament-season pair. Get the list of leagues with availible results using /list query to api")
				Base.encode16(Protobufs.FetchResultsMsgError.encode(response), case: :lower)
			_ ->
				response = Protobufs.FetchResultsMsg.new(results: response_list)
				Base.encode16(Protobufs.FetchResultsMsg.encode(response), case: :lower)
		end
		#origin header is needed for comfortable use of this api in front end 
        origin = case headers["origin"] do
			nil ->
				%{}
			_ ->
				%{"Access-Control-Allow-Origin" => headers["origin"]}
		end
		{200, Map.merge(origin, @headers), msg , state}
	end
	def handle_get_request("/"<>unknown_method, _query, _h, s) do
		{404, %{}, "Method "<>unknown_method<>"doesn't exist in our json api.", s}
	end
	def handle_get_request(_empty, _query, _h, s) do
		{404, %{}, "Please, choose the method.", s}
	end
end
