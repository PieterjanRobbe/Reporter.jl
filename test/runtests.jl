using Reporter

source = joinpath(dirname(pathof(Reporter)), "..", "histories")
dest = tempdir()

#
# MLMC
#
print("testing MLMC... ")
history_file = joinpath(source, "MLMC.jld2")
report(history_file, folder=dest, png=false)
println("done")

#
# MLQMC
#
print("testing MLQMC... ")
history_file = joinpath(source, "MLQMC.jld2")
report(history_file, folder=dest, png=false)
println("done")

#
# TDMC
#
print("testing MIMC, TD... ")
history_file = joinpath(source, "TDMC.jld2")
report(history_file, folder=dest, png=false)
println("done")

#
# ADMC
#
print("testing adaptive MIMC... ")
history_file = joinpath(source, "ADMC.jld2")
report(history_file, folder=dest, png=false)
println("done")
