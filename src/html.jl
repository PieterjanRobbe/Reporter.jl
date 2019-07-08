function make_html(h, folder)

	page = Vector{String}(undef, 0)
	push!(page, "<html>")
	push!(page, head(first(split(h[:name], "."))))
	push!(page, "<body>")
	push!(page, h1(first(split(h[:name], "."))))
	
	date = Dates.format(now(), DateFormat("dd/mm/yyyy"))
	time = Dates.format(now(), DateFormat("HH:MM"))
	push!(page, p(string("This report was generated on ", date, " at ", time, ".")))
	
	# TODO make a table with some options ...
	
	push!(page, h2("Estimated rates of expected value"))
	push!(page, image("E"))
	
	push!(page, h2("Estimated rates of variance"))
	push!(page, image("V"))
	
	haskey(h, :W) && push!(page, h2("Estimated rates of computational cost"))
	haskey(h, :W)&& push!(page, image("W"))
	
	push!(page, h2("Estimated rates of actual run time"))
	push!(page, image("T"))
	
	h[:type] <: Estimator{<:ML} && push!(page, h2("Distribution of number of samples"))
	h[:type] <: Estimator{<:ML} && push!(page, image("nb_of_samples"))
	
	push!(page, h2("Complexity: total run time vs requested RMSE"))
	push!(page, image("run_time_requested"))
	
	push!(page, h2("Complexity: total run time vs measured RMSE"))
	push!(page, image("run_time_measured"))
	
	haskey(h, :W) && push!(page, h2("Complexity: computational cost vs requested RMSE"))
	haskey(h, :W) && push!(page, image("comp_cost_requested"))
	
	haskey(h, :W) && push!(page, h2("Complexity: computational cost vs measured RMSE"))
	haskey(h, :W) && push!(page, image("comp_cost_measured"))
	
	1 < h[:ndims] ≤ 2 && push!(page, h2("Shape of the index set"))
	1 < h[:ndims] ≤ 2 && push!(page, image("index_set"))
	
	h[:type] <: Estimator{<:AD} && 1 < h[:ndims] ≤ 2 && push!(page, h2("Adaptive construction of the index set"))
	h[:type] <: Estimator{<:AD} && 1 < h[:ndims] ≤ 2 && push!(page, image("adaptive_index_set"))
	
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

image(str) = string("<center><img src='figures/", str, ".pdf' alt='", str, "' style='width:500px'></center>")
