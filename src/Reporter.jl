module Reporter

using Dates, JLD2, LaTeXStrings, PGFPlotsX, Reexport

@reexport using MultilevelEstimators

export report

include("pgf.jl")

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
	make_folder(h, folder)

	# make the figures
	make_figures(h, folder)

	# make the html file
	make_html(h, folder)
	
end

function make_folder(h, folder)
	!isdir(folder) && mkdir(folder)
	!isdir(joinpath(folder,"figures")) && mkdir(joinpath(folder,"figures"))
end

function make_figures(h, folder)

	# rates
	make_figures_rates(h, folder)

	# rates lattice rule (only QMC)
	# TODO

	# samples (only ML)

	# times, costs, times (actual), costs (actual)

	# index set (ony MI, 2d/3d)

	# adaptive index set (only MI, 2d/3d)
	
end

function make_html(h, folder)

end

function make_figures_rates(h, folder)

	d = h[:ndims]

	#
	# E
	#
	@pgf figure = Axis({rates_axis..., ylabel = L"\log_2(\mathbb{E}[|\;\cdot\;|])"})
	idx = Index(ntuple(i -> 1, d))
	x, y = get_rate_in_direction(h, idx, 0, :E)
	push!(figure, @pgf Plot({default_line_style..., color = "red"}, Table([x, y])))
	push!(figure, LegendEntry(latexstring("Q_{", index2ell(idx), "}")))
	for (i, idx) in enumerate( Iterators.drop(CartesianIndices(tuple(fill(0:1, d)...)), 1))
		x, y = get_rate_in_direction(h, idx, 1, :dE)
		push!(figure, @pgf Plot({default_line_style..., color = "red", style = line_style(i+1)}, Table([x, y])))
		push!(figure, LegendEntry(latexstring("\\Delta Q_{", index2ell(idx), "}")))
	end
	save(folder, "E", figure)

	#
	# V
	#
	@pgf figure = Axis({rates_axis..., ylabel = L"\log_2(\mathbb{V}[\;\cdot\;])"})
	idx = Index(ntuple(i -> 1, d))
	x, y = get_rate_in_direction(h, idx, 0, :V)
	push!(figure, @pgf Plot({default_line_style..., color = "blue"}, Table([x, y])))
	push!(figure, LegendEntry(latexstring("Q_{", index2ell(idx), "}")))
	for (i, idx) in enumerate( Iterators.drop(CartesianIndices(tuple(fill(0:1, d)...)), 1))
		x, y = get_rate_in_direction(h, idx, 1, :dV)
		push!(figure, @pgf Plot({default_line_style..., color = "blue", style = line_style(i+1)}, Table([x, y])))
		push!(figure, LegendEntry(latexstring("\\Delta Q_{", index2ell(idx), "}")))
	end
	save(folder, "V", figure)

	#
	# W
	#
	if haskey(h, :W)
		@pgf figure = Axis({rates_axis..., ylabel = L"\log_2(\textrm{cost}(\;\cdot\;))", legend_style_north_west...})
		for (i, idx) in enumerate( Iterators.drop(CartesianIndices(tuple(fill(0:1, d)...)), 1))
			x, y = get_rate_in_direction(h, idx, 0, :W)
			push!(figure, @pgf Plot({default_line_style..., color = "green", style = line_style(i+1)}, Table([x, y])))
			push!(figure, LegendEntry(latexstring("\\Delta Q_{", index2ell(idx), "}")))
		end
		save(folder, "W", figure)
	end

	#
	# T
	#
	@pgf figure = Axis({rates_axis..., ylabel = L"\log_2(\textrm{time}(\;\cdot\;))", legend_style_north_west...})
	for (i, idx) in enumerate( Iterators.drop(CartesianIndices(tuple(fill(0:1, d)...)), 1))
		x, y = get_rate_in_direction(h, idx, 0, :T)
		push!(figure, @pgf Plot({default_line_style..., color = "orange", style = line_style(i+1)}, Table([x, y])))
		push!(figure, LegendEntry(latexstring("\\Delta Q_{", index2ell(idx), "}")))
	end
	save(folder, "T", figure)
end

index2ell(index::Index{d}) where d = string(d > 1 ? "(" : "", join(map(i -> index[i] == 0 ? "0" : "\\ell", 1:length(index)), ", "), d > 1 ? ")" : "")

function get_rate_in_direction(h, idx, cntr, rate_symbol)
	x = Vector{Int64}(undef, 0)
	y = Vector{Float64}(undef, 0)
	while cntr*idx ∈ h[:index_set]
		push!(x, cntr)
		push!(y, log2(abs(h[rate_symbol][cntr*idx])))
		cntr += 1
	end
	x, y
end

function save(folder::AbstractString, filename::AbstractString, figure::PGFPlotsX.Axis)
	isempty(PGFPlotsX.CUSTOM_PREAMBLE) && push!(PGFPlotsX.CUSTOM_PREAMBLE, "\\usepackage{amsfonts}")

	td = TikzDocument(figure)
	print_tex(td)

	pgfsave(joinpath(folder, "figures", string(filename, ".pdf")), figure, latex_engine=PGFPlotsX.PDFLATEX)
	pgfsave(joinpath(folder, "figures", string(filename, ".tex")), figure, include_preamble=false, latex_engine=PGFPlotsX.PDFLATEX)
end

function make_html(h, folder)
	page = Vector{String}(undef, 0)
	push!(page, "<html>")
	push!(page, head(first(split(h[:name], "."))))
	push!(page, "<body>")
	push!(page, h1(first(split(h[:name], "."))))
	date = Dates.format(now(), DateFormat("dd/mm/yyyy"))
	time = Dates.format(now(), DateFormat("HH:MM"))
	push!(page, p(string("This report was generated on ", date, " at ", time, ".")))
	push!(page, h2("Estimated rates of expected value"))
	push!(page, image("figures/E"))
	push!(page, h2("Estimated rates of variance"))
	push!(page, image("figures/V"))
	if haskey(h, :W)
		push!(page, h2("Estimated rates of computational cost"))
		push!(page, image("figures/W"))
	end
	push!(page, h2("Estimated rates of actual run time"))
	push!(page, image("figures/T"))
	push!(page, "</body>")
	push!(page, "</html>")
	open(joinpath(folder, "index.html"), "w") do f
		write(f, join(page, "\n"))
	end
end

head(str) = string("<head>\n<title>", str, "</title></head>")

h1(str) = string("<h1>", str, "</h1>")

h2(str) = string("<h2>", str, "</h2>")

p(str) = string("<p>", str, "</p>")

image(str) = string("<center><img src='", str, ".pdf' alt='error displaying image' style='width:500px'></center>")

end # module
