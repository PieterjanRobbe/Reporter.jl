module Reporter

using Colors, Dates, JLD2, LaTeXStrings, PGFPlotsX, Printf, Reexport

@reexport using MultilevelEstimators

export report

include("pgf.jl")

include("figures.jl")

include("html.jl")

function report(name::AbstractString; folder="", include_preamble=false, png=true)
    try
        @load name history
        report(history, folder=folder, include_preamble=include_preamble, png=png)
    catch e
        if e isa SystemError
            @load joinpath(pwd(), name) history
            report(history, folder=folder, include_preamble=include_preamble, png=png)
        end
    end
end

function report(h::History; folder="", include_preamble=false, png=true)

	# make the required directories
        folder = folder == "" ? first(split(h[:name], ".")) : folder
	!isdir(folder) && mkdir(folder)
	!isdir(joinpath(folder,"figures")) && mkdir(joinpath(folder,"figures"))

	# make the figures
	make_figures(h, folder, include_preamble, png)

	# make the html file
	make_html(h, folder, png)

	# open html page
	try run(`open $(joinpath(folder, "index.html"))`) catch end
end

end # module
