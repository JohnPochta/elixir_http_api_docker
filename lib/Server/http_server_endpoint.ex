defmodule HttpServer.EndPoint do
	@moduledoc """
	  HttpServer.EndPoint module created like an router, which plays role of middleware and with help of query part next to the port - determine,
	  which format of data user wants to get. Middleware determine particular handler for processing requests in determined earlier implementation of API (json or protobuf) .
	"""
	@headers %{
      "Access-Control-Allow-Methods" => "GET",
      "Access-Control-Allow-Headers" => "Origin, Content-Type, Accept, Authorization, Access-Control-Allow-Credentials",
      "Access-Control-Allow-Credentials" => "true"
	}
	@doc """
		http/6 - function, which handles the http requests for Stargate HttpServer is calling http by default. This function is universal for all types of requests and it's very flexible and well proected by Stargate Developer. It's give an opportunity to use many possible tricks when you need.
		
		In some implementations of this functions some of arguments can be ignored specially cuz of there is no need for them
		## Parameters

		    - first argument: Atom, which define an type of received http request
		    - second argument: Url of request, which needs for pattren matching of needed handler function. "url_start"<>params - it's a trick for matching the part after url part that url should to match to be handled by this function.
		    - querystring: it's a map which represents the querystring of handling request in "key" => value form
		    - headers: it's a map which represents the headers of handling request in "key" => value form
		    - body: it's an body of http request, that is no needed and can be ignored just like  _body for request types, which don't contain a body
		    - state: it's an argument which thrown there for needs of http server library and contains of map with two default keys: host and socket, where host - it's server ip and socket address 
			

	"""
	@doc """
		http(:GET, "/protobuf_api"<>params, querystring, headers, _body, state) - match and start handling of requests for Protocol Buffers version of API
	"""
	def http(:GET, "/protobuf_api"<>params, querystring, headers, _body, state) do
		HttpServer.ProtobufApiHandler.handle_get_request(params, querystring, headers, state)
	end
	@doc """
		http(:GET, "/json_api"<>params, querystring, headers, _body, state) - match and start handling of requests for JSON version of API
	"""
	def http(:GET, "/json_api"<>params, querystring, headers, _body, state) do
		HttpServer.JsonApiHandler.handle_get_request(params, querystring, headers, state)
	end
	def http(method, params, querystring, headers, _body, state) do
		{404, @headers, "Please start your url with /protobuf_api or /json_api. We should to know what format of data you are expecting as a response.", state}
	end
end