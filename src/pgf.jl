#
# easy acccess to different markers
#
function marker(i)
	markers = ["*" "square*" "diamond*" "triangle*" "star*" "otimes"]
	n = length(markers)
	markers[mod(i - 1, n) + 1]
end

function mark_size(i)
	mark_sizes = ["1pt" "0.9pt" "1.4pt" "1.4pt" "1pt" "1pt"]
	n = length(mark_sizes)
	mark_sizes[mod(i - 1, n) + 1]
end

function line_style(i)
	line_styles = ["solid" "dotted" "densely dotted" "loosely dotted" "dashed" "densely dashed" "loosely dashed" "dashdotted" "densely dashdotted" "loosely dashdotted"]
	n = length(line_styles)
	line_styles[mod(i - 1, n) + 1]
end

#
# line styles
#
@pgf default_line_style = {
						   mark = "*",
						   mark_size = "1pt",
						   line_cap = "round",
						   mark_options = "solid", 
						   }

#
# legend styles
#
@pgf legend_style_south_west = {legend_style = "{draw=none, font=\\small, at={(0.03,0.03)}, anchor=south west, fill=none, legend cell align=left}"}
@pgf legend_style_south_east = {legend_style = "{draw=none, font=\\small, at={(0.97,0.03)}, anchor=south east, fill=none, legend cell align=left}"}
@pgf legend_style_north_west = {legend_style = "{draw=none, font=\\small, at={(0.03,0.97)}, anchor=north west, fill=none, legend cell align=left}"}
@pgf legend_style_north_east = {legend_style = "{draw=none, font=\\small, at={(0.97,0.97)}, anchor=north east, fill=none, legend cell align=left}"}
@pgf legend_style_outside = {legend_style = "{draw=none, font=\\small, at={(1.03,0.97)}, anchor=north west, fill=none, legend cell align=left}"}

#
# axis
#
@pgf default_axes = {
					 ticklabel_style = "{font=\\small}",
					 major_tick_length = "2pt",
					 "every_tick/.style" = "{black, line cap=round}",
					 axis_on_top,
					 legend_style_south_west...
					 }

@pgf rates_axis = {
				   default_axes...,
				   xlabel = L"$\ell$",
				   xtick_distance = "1",
				   }

@pgf nb_of_samples_axis = {
					 default_axes...,
					 xlabel = L"$\ell$",
					 xtick_distance = "1",
					 ylabel = L"N_\ell",
					 ymode = "log",
					 legend_style_outside...
					 }

@pgf complexity_axis = {
					 default_axes...,
					 xmode = "log",
					 ymode = "log",
					 legend_style_north_east...
					 }

@pgf index_set_2d = {
					 xmin = "-0.1",
					 ymin = "-0.1",
					 xticklabel = "{}",
					 xmajorticks = "false",
					 yticklabel = "{}",
					 ymajorticks = "false",
					 axis_line_style = "{ultra thin, draw opacity=0}",
					 axis_equal
					 }

#
# colors
#
function jet(n)
	RGB{Float64}[RGB(
					 clamp(min(4x-1.5, -4x+4.5), 0, 1),
					 clamp(min(4x-0.5, -4x+3.5), 0, 1),
					 clamp(min(4x+0.5, -4x+2.5), 0, 1))
				 for x in range(0, stop=1 , length=n)]
end

#
# preamble
#
function preamble()
	p = String[]

	# packages
	push!(p, "\\usepackage{amsfonts}")

	# macros
	for file in ["triangle" "square" "cube"]
		s = open(joinpath(dirname(pathof(Reporter)), string(file, ".txt"))) do file
			read(file, String)
		end
		push!(p, s)
	end

	return p
end
