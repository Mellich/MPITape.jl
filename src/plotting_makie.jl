using WGLMakie
using Colors

function plot_edges(scene, edges::Array{Tuple{MPIEvent, MPIEvent}})
    arrows = []
    for (src, dst) in edges
        push!(arrows,
              arrows!(scene, [src.t_end], [src.rank], [dst.t_end - src.t_end],
                      [dst.rank - src.rank]))
    end
    arrows
end

function event_to_rect(scene, ev::MPIEvent; color = :blue)
    poly!(scene, [Rect(ev.t_start, ev.rank - 0.1, ev.t_end - ev.t_start, 0.2)],
          color = color, label = replace(string(ev.f), "MPI_" => ""))
end

function plot_merged(tape::Array{MPIEvent})
    f = Figure(resolution = (800, 500))
    datagrid = GridLayout(f[1, 1], ncols = 2)
    ax = Axis(datagrid[1, 1])
    hslide = Makie.Slider(datagrid[2, 1], horizontal = true, range = 0:1:0)
    # on(hslide.value) do v
    #     ax.
    # end
    unique_calls = unique([ev.f for ev in tape])
    palette = distinguishable_colors(length(unique_calls), [RGB(1, 1, 1), RGB(0, 0, 0)],
                                     dropseed = true)
    legendrects = Dict()
    for mpievent in tape
        idx = findfirst(x -> x == mpievent.f, unique_calls)
        legendrects[string(mpievent.f)] = event_to_rect(ax, mpievent,
                                                        color = palette[idx])
    end
    infogrid = GridLayout(f[1, 2], ncols = 2, valign = :top, halign = :left,
                          width = Fixed(200))
    Legend(infogrid[1, 1], [legendrects[l] for l in unique_calls],
           [replace(u, "MPI_" => "") for u in unique_calls],
           label = "MPI Call", valign = :top, halign = :left)
    Label(infogrid[2, 1], text = "MPI Info", height = Relative(2 / 3), valign = :top)
    edges = get_edges(tape)
    plot_edges(ax, edges)
    colgap!(f.layout, 5)
    # rowsize!(grid, 1, Auto(true))
    # xlabel!(ax, "Execution time [s]")
    # ylabel!(ax, "MPI Rank")
    return f
end