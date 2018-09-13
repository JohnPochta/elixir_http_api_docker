defmodule EtsTable do
    @moduledoc """
      EtsTable module was created for execution of operations with the ets tables, which contained API data and makes api responces are really faster,
      cuz there will be no need to read data from file or DB. ETS table - it's a correct choice for API data storage in Elixir Apps. 
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
        сreate_table/0 function creates the ets tables with declared name and options that we need as data storage 
    """
    def create_table do
        try do 
          :ets.new(@results_table, @table_opts) 
          :ets.new(@pairs_list_table, @pairs_list_table_opts)
        catch e,r-> :ignore end
    end
    @doc """
      select pairs list/0 function created for extracting from ets table all existing records in pairs_list_table    
    """
    def select_pairs_list do
        :ets.match_object(@pairs_list_table, {{:"_", :"_"}})
    end
    @doc """
        select_pairs_list/0 function created for exctracting from ets table all existing records in results_table by given tournament and season params
    """
    def select_by_season_and_tournament(season, tournament)  do
      :ets.match_object(@results_table, {:"_", :"_", :"_", :"_", tournament, :"_", :"_", :"_", :"_", :"_", :"_", season})
    end
   @doc """
      start_upload(stats) function created for uploading data to ets tables, which we have in our App
    """
    def start_upload(stats) do
      Enum.each(stats, fn(x)-> 
        :ets.insert(@results_table, {x.id, x.home_team, x.away_team, x.date, x.tournament, x.ftag, x.fthg, x.ftr, x.htag, x.hthg, x.htr, x.season})
        :ets.insert(@pairs_list_table, {{x.tournament, x.season}})
      end)
      {:ok}
    end
end