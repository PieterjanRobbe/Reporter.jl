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

function report(h::History, folder::AbstractString;include_preamble=false)

	# make the required directories
	!isdir(folder) && mkdir(folder)
	!isdir(joinpath(folder,"figures")) && mkdir(joinpath(folder,"figures"))

	# make the figures
	make_figures(h, folder,include_preamble)

	# make the html file
	make_html(h, folder)

	# open html page
	try run(`open $(joinpath(folder, "index.html"))`) catch end
end

end # module
