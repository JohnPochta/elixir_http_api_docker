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
    @doc """
        сreate_table/0 function create the ets tables with declared name and options
    """
    def create_table do
        try do 
          :ets.new(@results_table, @table_opts) 
          :ets.new(@pairs_list_table, @pairs_list_table_opts)
        catch e,r-> :ignore end
    end
    @doc """
        select_pairs_list/0 function created for exctracting from ets table all exist records in pairs_list_table
    """
    def select_pairs_list do
        :ets.match_object(@pairs_list_table, {:"_", :"_"})
    end
    @doc """
        select_pairs_list/0 function created for exctracting from ets table all exist records in results_table by given tournament and season params
    """
    def select_by_season_and_tournament(season, tournament)  do
      :ets.match_object(@results_table, {:"_", :"_", :"_", :"_", tournament, :"_", :"_", :"_", :"_", :"_", :"_", season})
    end
   @doc """
      start_upload(stats) function created for uploading data to ets tables, которые используются в этом приложении
    """
    def start_upload(stats) do
      Enum.each(stats, fn(x)-> 
        :ets.insert(@results_table, {x.id, x.home_team, x.away_team, x.date, x.tournament, x.ftag, x.fthg, x.ftr, x.htag, x.hthg, x.htr, x.season})
        :ets.insert(@pairs_list_table, {x.tournament, x.season})
      end)
      {:ok}
    end
end