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
	line_styles = ["solid" "dashed" "dotted" "dashdotted" "densly dotted" "loosly dotted" "densly dashed" "loosley dashed"]
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

