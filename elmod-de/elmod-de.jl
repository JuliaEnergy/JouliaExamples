#############################################################################
# Joulia
# A Large-Scale Spatial Power System Model for Julia
# See https://github.com/JuliaEnergy/Joulia.jl
#############################################################################
# Example: ELMOD-DE

using Joulia

using DataFrames, CSV
using Gurobi

# data load for 2015 sample data
# see http://doi.org/10.5281/zenodo.1044463
pp_df = CSV.read("data_2015/power_plants.csv")
avail_con_df = CSV.read("data_2015/avail_con.csv")
prices_df = CSV.read("data_2015/prices.csv")

storages_df = CSV.read("data_2015/storages.csv")

lines_df = CSV.read("data_2015/lines.csv")

load_df = CSV.read("data_2015/load.csv")
nodes_df = CSV.read("data_2015/nodes.csv")
exchange_df = CSV.read("data_2015/exchange.csv")

res_df = CSV.read("data_2015/res.csv")
avail_pv = CSV.read("data_2015/avail_pv.csv")
avail_windon = CSV.read("data_2015/avail_windon.csv")
avail_windoff = CSV.read("data_2015/avail_windoff.csv")

avail = Dict(:PV => avail_pv,
	:WindOnshore => avail_windon,
	:WindOffshore => avail_windoff,
	:global => avail_con_df)

# generation of Joulia data types
pp = PowerPlants(pp_df, avail=avail_con_df, prices=prices_df)
storages = Storages(storages_df)
lines = Lines(lines_df)
nodes = Nodes(nodes_df, load_df, exchange_df)
res = RenewableEnergySource(res_df, avail)

# generation of the Joulia model
elmod = JouliaModel(pp, res, storages, nodes, lines)

# sclicing the data in weeks with the first full week starting at hour 49
slices = week_slices(49)

# running the Joulia model for week 30 using the Gurobi solver
results = run_model(elmod, slices[30], solver=GurobiSolver())
