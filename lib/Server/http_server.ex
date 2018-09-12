defmodule HttpServer do
	@moduledoc """
	  HttpServer module creates an HTTPServer Instance using Stargate library from there github.com/vans163/stargate . 
	  This library very лёгкая and универсальная и может быть использована также для web-sockets server.
	  For start working with this Erlang Server realization you have to define EndPoints for different types of Server. In this particular situation it's an :http .
	  The Server Instance in this module - can be restarted after shutdowns until parent process is alive, cuz it's under Supervisor. 
	  Thinness:
	  Stargate library, was developed by my last job partner from Canada. It's recomended to use Stargate for Servers app, 
	  cuz many tests showes that this erlang http server realization demonstrates the performance better that in all familiar to me other libraries.
	  In description of this library - pointed that there's no full HTTP spec. , but i've never met something that was unsupportable by this Server. It's an brilliant. 
	"""
	def start_link(pool_ip, port), do:
        Supervisor.start_link(__MODULE__, [pool_ip, port], name: __MODULE__)
    def init([pool_ip, port]) do
    	{:ok, _} = :application.ensure_all_started(:stargate)

	    webserver = %{
	        port: port,
	        ip: pool_ip,
	        hosts: %{
	            {:http, "*"}=> {HttpServer.EndPoint, %{}},
	        },
	    }
	    {:ok, _Pid} = :stargate.warp_in(webserver)
	    children = []
	    Supervisor.init(children, strategy: :one_for_one, max_seconds: 1, max_restarts: 999999999999)
    end
end