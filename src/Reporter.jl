module Reporter

using Colors, Dates, JLD2, LaTeXStrings, PGFPlotsX, Printf, Reexport

@reexport using MultilevelEstimators

export report

include("pgf.jl")

include("figures.jl")

include("html.jl")

function report(name::AbstractString)
	@load name history
	report(history)
end

function report(h::History)
	folder = first(split(h[:name], "."))
	report(h, folder)
end

function report(h::History, folder::AbstractString)
	
	# make the required directories
	!isdir(folder) && mkdir(folder)
	!isdir(joinpath(folder,"figures")) && mkdir(joinpath(folder,"figures"))

	# make the figures
	make_figures(h, folder)

	# make the html file
	make_html(h, folder)

	# open html page
	run(`open $(joinpath(folder, "index.html"))`)
	
end

end # module
