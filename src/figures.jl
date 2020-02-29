function make_figures(h, folder, include_preamble, png)

	# rates
	make_figures_rates(h, folder, include_preamble, png)
	# TODO and contours for MIMC 2d

	# rates lattice rule (only QMC)
	# TODO

	# samples (only ML)
	h[:type] <: Estimator{<:ML} && make_figure_samples(h, folder, include_preamble, png)
	# TODO and contours for MIMC 2d

	# times, costs, times (actual), costs (actual)
	make_figure_complexity(h, folder, include_preamble, png)

	# index set (ony MI, 2d/ TODO: 3d)
	1 < h[:ndims] ≤ 2 && make_figure_index_sets(h, folder, include_preamble, png)

	# adaptive index set (only MI, 2d/ TODO: 3d)
	h[:type] <: Estimator{<:AD} && 1 < h[:ndims] ≤ 2 && make_figure_adaptive_index_sets(h, folder, include_preamble, png)

end

function make_figures_rates(h, folder, include_preamble, png)

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
	save(folder, "E", figure, include_preamble, png)

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
	save(folder, "V", figure, include_preamble, png)

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
		save(folder, "W", figure, include_preamble, png)
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
	save(folder, "T", figure,include_preamble, png)
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

function make_figure_samples(h, folder, include_preamble, png)
	@pgf figure = Axis({nb_of_samples_axis...})
	n = length(h)
	colors = jet(n)
	for tol in n:-1:1
		y = filter(i -> i > 0, h[tol][:nb_of_samples])
		x = 0:length(y)-1
		push!(figure, @pgf Plot({default_line_style..., color = colors[tol]}, Table([x, y])))
		push!(figure, LegendEntry(string("\$\\varepsilon=\$", @sprintf("%4.3e", h[tol][:tol]))))
	end
	save(folder, "nb_of_samples", figure, include_preamble, png)
end

function make_figure_complexity(h, folder, include_preamble, png)
	#
	# run times
	#
	@pgf figure = Axis({complexity_axis..., xlabel="requested rmse \$\\varepsilon\$", ylabel="total run time"})
	x = [h[i][:tol] for i in 1:length(h)]
	y = [sum(h[j][:elapsed] for j in 1:i) for i in 1:length(h)]
	push!(figure, @pgf Plot({default_line_style..., color = "blue"}, Table([x, y])))
	push!(figure, "\\littletriangle{2};")
	save(folder, "run_time_requested", figure, include_preamble, png)

	@pgf figure = Axis({complexity_axis..., xlabel="measured rmse \$\\varepsilon\$", ylabel="total run time"})
	x = [h[i][:rmse] for i in 1:length(h)]
	push!(figure, @pgf Plot({default_line_style..., color = "blue"}, Table([x, y])))
	push!(figure, "\\littletriangle{2};")
	save(folder, "run_time_measured", figure, include_preamble, png)

	#
	# computational costs
	#
	if haskey(h, :W)
		@pgf figure = Axis({complexity_axis..., xlabel="requested rmse \$\\varepsilon\$", ylabel="computational cost"})
		x = [h[i][:tol] for i in 1:length(h)]
		y = [sum(h[i][:W][j - one(j)]*h[i][:nb_of_samples][j] for j in CartesianIndices(h[i][:nb_of_samples]) if haskey(h[i][:W], j - one(j))) for i in 1:length(h)]
		push!(figure, @pgf Plot({default_line_style..., color = "red"}, Table([x, y])))
		push!(figure, "\\littletriangle{2};")
		save(folder, "comp_cost_requested", figure, include_preamble, png)

		@pgf figure = Axis({complexity_axis..., xlabel="measured rmse \$\\varepsilon\$", ylabel="computational cost"})
		x = [h[i][:rmse] for i in 1:length(h)]
		push!(figure, @pgf Plot({default_line_style..., color = "red"}, Table([x, y])))
		push!(figure, "\\littletriangle{2};")
		save(folder, "comp_cost_measured", figure, include_preamble, png)
	end
end

function make_figure_index_sets(h, folder, include_preamble, png)
	ncols = 2
	nrows = ceil(Int64, length(h)/ncols)
	m = maximum(maximum(h[:index_set]).I) + 1.1
	@pgf gp = GroupPlot({group_style = {group_size = "2 by $nrows"}})
	for tol in 1:length(h)
		@pgf push!(gp, {index_set_2d..., xmax = m, ymax = m, xlabel = string("\\Large\$\\varepsilon = \$ ", @sprintf("%4.3e", h[tol][:tol]))})
		for index in h[tol][:current_index_set]
			push!(gp, string("\\drawsquare{", index[1], "}{", index[2], "}{white!90!black}"))
		end
	end
	save(folder, "index_set", gp, include_preamble, png)
end

function make_figure_adaptive_index_sets(h, folder, include_preamble, png)
	ncols = 2
	nrows = ceil(Int64, (length(h[:logbook])+1)/ncols)
	m = maximum(maximum(h[:current_index_set]).I) + 1.1
	@pgf gp = GroupPlot({group_style = {group_size = "2 by $nrows"}})
	@pgf push!(gp, {index_set_2d..., xmax = m, ymax = m})
	shift = (m - 1.1)/2
	push!(gp, string("\\drawsquare{", 0, "}{", 0, "}{white!90!black}"))
	push!(gp, string("\\drawsquare{", 0, "}{", shift, "}{orange!50!white}"))
	push!(gp, string("\\drawsquare{", 0, "}{", 2*shift, "}{blue!50!white}"))
	push!(gp, string("\\node[anchor=west] at (axis cs:1,", 0.5, ") {\\Large \\,= old index set};"))
	push!(gp, string("\\node[anchor=west] at (axis cs:1,", shift + 0.5, ") {\\Large \\,= active index set};"))
	push!(gp, string("\\node[anchor=west] at (axis cs:1,", 2*shift + 0.5, ") {\\Large \\,= maximum profit};"))
	for i in 1:length(h[:logbook])
		@pgf push!(gp, {index_set_2d..., xmax = m, ymax = m, xlabel = "\\Large \$L = $(i-1)\$"})
		old, active, max_index = h[:logbook][i]
		delete!(old, max_index)
		for index in old
			push!(gp, string("\\drawsquare{", index[1], "}{", index[2], "}{white!90!black}"))
		end
		for index in active
			push!(gp, string("\\drawsquare{", index[1], "}{", index[2], "}{orange!50!white}"))
		end
		i > 1 && push!(gp, string("\\drawsquare{", max_index[1], "}{", max_index[2], "}{blue!50!white}"))
	end
	save(folder, "adaptive_index_set", gp, include_preamble, png)
end

function save(folder::AbstractString, filename::AbstractString, figure::PGFPlotsX.AxisLike, include_preamble, png)
	isempty(PGFPlotsX.CUSTOM_PREAMBLE) && append!(PGFPlotsX.CUSTOM_PREAMBLE, preamble())

        # save the TeX file anyway
	pgfsave(joinpath(folder, "figures", string(filename, ".tex")), figure, include_preamble=include_preamble, latex_engine=PGFPlotsX.PDFLATEX)
	try
            # try to render a pdf / png picture
            ext = png ? ".png" : ".pdf"
	    pgfsave(joinpath(folder, "figures", string(filename, ext)), figure, latex_engine=PGFPlotsX.PDFLATEX, dpi=1200)
	catch e
	end
end
