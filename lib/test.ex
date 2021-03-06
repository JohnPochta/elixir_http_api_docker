defmodule Test do
    @moduledoc """
        The module from which the application starts
    """

    use Application
    @doc """
     csv_init(path) - function created for upload data from given csv file and upload it to ets table using EtsTable.start_upload(stats) function.
    """
    def csv_init(path) do
        stream = File.stream!(path) |> CSV.decode
        data = Enum.to_list(stream.enum)
        [ _header | records ] = data
        stats = Enum.map(records, fn x -> 
            try do
                {:ok, row_data} = x
                #FTHG and HG = Full Time Home Team Goals
                #FTAG and AG = Full Time Away Team Goals
                #FTR and Res = Full Time Result (H=Home Win, D=Draw, A=Away Win)
                #HTHG = Half Time Home Team Goals
                #HTAG = Half Time Away Team Goals
                #HTR = Half Time Result (H=Home Win, D=Draw, A=Away Win)
                [id, tournament, season, date, home_team, away_team, fthg, ftag, ftr, hthg, htag, htr] = row_data
                [day, month, year] = String.split(date, "/")
        		date = "20#{year}-#{month}-#{day}"
                %{
                	id: String.to_integer(id),
                	home_team: home_team, 
                	away_team: away_team, 
                	date: Date.from_iso8601!(date), 
                	tournament: tournament, 
                	ftag: ftag, 
                	fthg: fthg, 
                	ftr: ftr, 
                	htag: htag, 
                	hthg: hthg, 
                	htr: htr,
                	season: String.to_integer(season)
                }

            catch _e,r ->
                IO.inspect r
                nil
            end
        end)
        EtsTable.start_upload(stats)
    end 
    @doc """
     start(_type, _args) - function that's called just after start of the application and do next things: 
     EtsTable.create_table() - Creates ets tables for storage data that will used in the future for handling API calls 
     Test.csv_init("data.csv") - Reads data from Test.csv_init("data.csv") and upload it to ets using 
     Starts the application with a child process http server, the stable work of which is provided by the supervisor supervisor(HttpServer, [pool_ip, port]).
    """
    def start(_type, _args) do
      import Supervisor.Spec, warn: false

      IO.puts "Hello world"

      [ip_address: pool_ip, port: port] = Application.get_env(:test, __MODULE__)

      EtsTable.create_table()

      Test.csv_init("data.csv")

      children = [
        supervisor(HttpServer, [pool_ip, port])
      ]
      Supervisor.start_link(children, strategy: :one_for_one)
  end
end
