defmodule HttpServer.EndPoint do
	@moduledoc """
	  HttpServer.EndPoint module служит в качестве роутера, который исполняет роль middleware и в зависимости от части запроса следующей за портом - определяет,
	  which format of data want to get user which create the request - в зависимости от чего данное миддлваре определяет соотвествующий handler для обработки запроса
	"""
	@headers %{
      "Access-Control-Allow-Methods" => "GET",
      "Access-Control-Allow-Headers" => "Origin, Content-Type, Accept, Authorization, Access-Control-Allow-Credentials",
      "Access-Control-Allow-Credentials" => "true"
	}
	@doc """
		http/6 - function, which handles the http requests for Stargate HttpServer called http by default. This function is универсальная для всех типов запросов, но тем не менее она не только очень гибкая, но и очень грамотно спроектирована, что развязывает руки.
		
		In some implementations of this functions some of arguments can be ignored specially cuz of there is no need for them
		## Parameters

		    - first argument: Atom, which define an type of received http request
		    - second argument: Url of request, which needs for pattren matching of needed handler function. "url_start"<>params - is a trick for выделение неинтересующей нас на данном этапе части url, но которая может пригодится нам в дальнейшем
		    - querystring: it's a map which represents the querystring of handling request in "key" => value form
		    - headers: it's a map which represents the headers of handling request in "key" => value form
		    - body: it's an body of http request, that is no needed fand can be ignored just like  _body for types which don't contain a body
		    - state: it's an argument which пробрасывается, for needs of http server library and contains of map with to default keys: host and socket, where host - it's server ip and socket it's address обслуживающего данный запрос socket-a 
			

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