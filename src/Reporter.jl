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

<<<<<<< HEAD
function report(h::History, folder::AbstractString;include_preamble=false)
=======
function report(h::History, folder::AbstractString)
>>>>>>> 80601260bdf66c5941fdadc097a508fbd70e6518

	# make the required directories
	!isdir(folder) && mkdir(folder)
	!isdir(joinpath(folder,"figures")) && mkdir(joinpath(folder,"figures"))

	# make the figures
<<<<<<< HEAD
	make_figures(h, folder,include_preamble)
=======
	make_figures(h, folder)
>>>>>>> 80601260bdf66c5941fdadc097a508fbd70e6518

	# make the html file
	make_html(h, folder)

	# open html page
	try run(`open $(joinpath(folder, "index.html"))`) catch end
end

end # module
