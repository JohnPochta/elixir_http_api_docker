defmodule EtsTable do
    @moduledoc """
      EtsTable module was created for servicing the ets tables, which contain API data, and will make api responces are really faster,
      cuz there will be no to read data from file or DB. ETS table - it's a correct choice for API data storage in Elixir Apps. 
    """
    @results_table :ets_table
    @pairs_list_table :ets_table
    @table_opts [:set, 
        :public, 
        :named_table,
        {:read_concurrency, true},
        {:write_concurrency, true}
    ]
    @pairs_list_table_opts [:bag, 
        :public, 
        :named_table,
        {:read_concurrency, true},
        {:write_concurrency, true}
    ]

    def create_table do
        try do 
          :ets.new(@results_table, @table_opts) 
          :ets.new(@pairs_list_table, @pairs_list_table_opts)
        catch e,r-> :ignore end
    end

    def select_pairs_list do
        :ets.match_object(@pairs_list_table, {:"_", :"_"})
    end

    def select_by_season_and_tournament(season, tournament)  do
      :ets.match_object(@results_table, {:"_", :"_", :"_", :"_", tournament, :"_", :"_", :"_", :"_", :"_", :"_", season})
    end
    def start_upload(stats) do
      #one of the main features of elixir is ets table , which allow us to avoid to violence of db in api servers , cuz we can store data for get request in it.
      #So I decided to upload DB data to ets table when api start working. Also ets table has own gen server which service updating of db and allow us to communicate with this table.
      Enum.each(stats, fn(x)-> 
        :ets.insert(@results_table, {x.id, x.home_team, x.away_team, x.date, x.tournament, x.ftag, x.fthg, x.ftr, x.htag, x.hthg, x.htr, x.season})
        :ets.insert(@pairs_list_table, {x.tournament, x.season})
      end)
      IO.inspect :ets.match_object(@pairs_list_table, {:"_", :"_"})
      {:ok}
    end
end