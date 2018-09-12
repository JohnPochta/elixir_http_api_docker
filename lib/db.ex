defmodule DB_Connection do
	use GenServer

	def start_link(username, password, database) do
		GenServer.start_link(__MODULE__, [username, password, database], name: __MODULE__)
	end

    def init([username, password, database]) do
        {:ok, p} = Postgrex.start_link(username: username, password: password, database: database)
        IO.inspect "DB_Connection STARTED"
        {:ok, %{db_pid: p}}
    end

    def sql_date_from_csv_data(str_date) do     
        [day, mon, year] = String.split(str_date, "/")
        year = "20"<>year
        hour = String.pad_leading("#{0}", 2, "0")
        min = String.pad_leading("#{0}", 2, "0")
        sec = String.pad_leading("#{0}", 2, "0")
        "#{year}-#{mon}-#{day} #{hour}:#{min}:#{sec}"
    end

    def handle_call({:exec, query}, from, s) do
      	{:ok, resp} = Postgrex.query(s.db_pid, query, [])
    	{:reply, {:ok, resp} ,s}
    end

    def handle_call({:select, query}, from, s) do
        {:ok, resp} = Postgrex.query(s.db_pid, query, [])
        r = normalize(resp)
        {:reply, {:ok, r} ,s}
    end

    defp normalize(r) do
    	normalize(r.rows, r.columns)
    end

    defp normalize(rows, columns) do
        Enum.map(rows, fn(l)->
            {_,m} = Enum.reduce(l, {1, %{}}, fn(v, {i, a})->
                k = :lists.nth(i, columns)
                k = String.to_atom(k)
                {i+1, Map.put(a, k, v)}
            end)
            m
        end)
    end

end