# Parts of this code were taken / derived from NetworkX. See LICENSE for
# licensing details.

"""
    CompleteGraph(n)

Create an undirected [complete graph](https://en.wikipedia.org/wiki/Complete_graph)
with `n` vertices.
"""
function CompleteGraph(n::T) where {T <: Integer}
    n <= 0 && return SimpleGraph{T}(0)
    ne = Int(n * (n - 1) ÷ 2)

    fadjlist = Vector{Vector{T}}(undef, n)
    @inbounds @simd for u = 1:n
        listu = Vector{T}(undef, n-1)
        listu[1:(u-1)] = UnitRange{T}(1, u - 1)
        listu[u:(n-1)] = UnitRange{T}(u + 1, n)
        fadjlist[u] = listu
    end
    return SimpleGraph(ne, fadjlist)
end


"""
    CompleteBipartiteGraph(n1, n2)

Create an undirected [complete bipartite graph](https://en.wikipedia.org/wiki/Complete_bipartite_graph)
with `n1 + n2` vertices.
"""
function CompleteBipartiteGraph(n1::T, n2::T) where {T <: Integer}
    (n1 < 0 || n2 < 0) && return SimpleGraph{T}(0)
    Tw = widen(T)
    nw = Tw(n1) + Tw(n2)
    n = T(n1 + n2)  # checks if T is large enough for n1 + n2

    ne = Int(n1) * Int(n2)

    fadjlist = Vector{Vector{T}}(undef, n)
    range1 = UnitRange{T}(1, n1)
    range2 = UnitRange{T}(n1 + 1, n)
    @inbounds @simd for u in range1
        fadjlist[u] = Vector{T}(range2)
    end
    @inbounds @simd for u in range2
        fadjlist[u] = Vector{T}(range1)
    end
    return SimpleGraph(ne, fadjlist)
end


"""
    CompleteDiGraph(n)

Create a directed [complete graph](https://en.wikipedia.org/wiki/Complete_graph)
with `n` vertices.
"""
function CompleteDiGraph(n::T) where {T <: Integer}
    n <= 0 && return SimpleDiGraph{T}(0)

    ne = Int(n * (n - 1))
    fadjlist = Vector{Vector{T}}(undef, n)
    badjlist = Vector{Vector{T}}(undef, n)
    @inbounds @simd for u = one(T):n
        listu = Vector{T}(undef, n-1)
        listu[1:(u-1)] = UnitRange{T}(1, u - 1)
        listu[u:(n-1)] = UnitRange{T}(u + 1, n)
        fadjlist[u] = listu
        badjlist[u] = deepcopy(listu)
    end
    return SimpleDiGraph(ne, fadjlist, badjlist)
end

"""
    StarGraph(n)

Create an undirected [star graph](https://en.wikipedia.org/wiki/Star_(graph_theory))
with `n` vertices.
"""
function StarGraph(n::T) where {T <: Integer}
    n <= 0 && return SimpleGraph{T}(0)

    ne = Int(n - 1)
    fadjlist = Vector{Vector{T}}(undef, n)
    @inbounds fadjlist[1] = Vector{T}(2:n)
    @inbounds @simd for u = 2:n
        fadjlist[u] = T[1]
    end
    return SimpleGraph(ne, fadjlist)
end

"""
    StarDiGraph(n)

Create a directed [star graph](https://en.wikipedia.org/wiki/Star_(graph_theory))
with `n` vertices.
"""
function StarDiGraph(n::T) where {T <: Integer}
    n <= 0 && return SimpleDiGraph{T}(0)

    ne = Int(n - 1)
    fadjlist = Vector{Vector{T}}(undef, n)
    badjlist = Vector{Vector{T}}(undef, n)
    @inbounds fadjlist[1] = Vector{T}(2:n)
    @inbounds badjlist[1] = T[]
    @inbounds @simd for u = 2:n
        fadjlist[u] = T[]
        badjlist[u] = T[1]
    end
    return SimpleDiGraph(ne, fadjlist, badjlist)
end

"""
    PathGraph(n)

Create an undirected [path graph](https://en.wikipedia.org/wiki/Path_graph)
with `n` vertices.
"""
function PathGraph(n::T) where {T <: Integer}
    n <= 1 && return SimpleGraph(n)

    ne = Int(n - 1)
    fadjlist = Vector{Vector{T}}(undef, n)
    @inbounds fadjlist[1] = T[2]
    @inbounds fadjlist[n] = T[n - 1]

    @inbounds @simd for u = 2:(n-1)
        fadjlist[u] = T[u - 1, u + 1]
    end
    return SimpleGraph(ne, fadjlist)
end

"""
    PathDiGraph(n)

Creates a directed [path graph](https://en.wikipedia.org/wiki/Path_graph)
with `n` vertices.
"""
function PathDiGraph(n::T) where {T <: Integer}
    n <= 1 && return SimpleDiGraph(n)

    ne = Int(n - 1)
    fadjlist = Vector{Vector{T}}(undef, n)
    badjlist = Vector{Vector{T}}(undef, n)

    @inbounds fadjlist[1] = T[2]
    @inbounds badjlist[1] = T[]
    @inbounds fadjlist[n] = T[]
    @inbounds badjlist[n] = T[n - 1]

    @inbounds @simd for u = 2:(n-1)
        fadjlist[u] = T[u + 1]
        badjlist[u] = T[u - 1]
    end
    return SimpleDiGraph(ne, fadjlist, badjlist)
end

"""
    CycleGraph(n)

Create an undirected [cycle graph](https://en.wikipedia.org/wiki/Cycle_graph)
with `n` vertices.
"""
function CycleGraph(n::Integer)
    g = SimpleGraph(n)
    for i = 1:(n - 1)
        add_edge!(g, SimpleEdge(i, i + 1))
    end
    add_edge!(g, SimpleEdge(n, 1))
    return g
end

"""
    CycleDiGraph(n)

Create a directed [cycle graph](https://en.wikipedia.org/wiki/Cycle_graph)
with `n` vertices.
"""
function CycleDiGraph(n::T) where {T <: Integer}
    n <= 0 && return SimpleDiGraph(n)  # check if correct
    n == 1 && return SimpleDiGraph(Edge{T}.([(1, 2)]))

    ne = Int(n)
    fadjlist = Vector{Vector{T}}(undef, n)
    badjlist = Vector{Vector{T}}(undef, n)
    @inbounds fadjlist[1] = T[2]
    @inbounds badjlist[1] = T[n]
    @inbounds fadjlist[n] = T[1]
    @inbounds badjlist[n] = T[n-1]

    @inbounds @simd for u = 2:(n-1)
        fadjlist[u] = T[u + 1]
        badjlist[u] = T[u + -1]
    end
    return SimpleDiGraph(ne, fadjlist, badjlist)
end


"""
    WheelGraph(n)

Create an undirected [wheel graph](https://en.wikipedia.org/wiki/Wheel_graph)
with `n` vertices.
"""
function WheelGraph(n::T) where {T <: Integer}
    n <= 1 && return SimpleGraph(n)
    n <= 3 && return CycleGraph(n)
 
    ne = Int(2 * (n - 1))
    fadjlist = Vector{Vector{T}}(undef, n)
    @inbounds fadjlist[1] = Vector{T}(2:n)
    @inbounds fadjlist[2] = T[1, 3, n]
    @inbounds fadjlist[n] = T[1, 2, n - 1]

    @inbounds @simd for u = 3:(n-1)
        fadjlist[u] = T[1, u - 1, u + 1]
    end
    return SimpleGraph(ne, fadjlist)
end

"""
    WheelDiGraph(n)

Create a directed [wheel graph](https://en.wikipedia.org/wiki/Wheel_graph)
with `n` vertices.
"""
function WheelDiGraph(n::T) where {T <: Integer}
    n <= 2 && return PathDiGraph(n)
    n == 3 && return SimpleDiGraph(Edge{T}.([(1,2),(1,3),(2,3),(3,2)]))
 
    ne = Int(2 * (n - 1))
    fadjlist = Vector{Vector{T}}(undef, n)
    badjlist = Vector{Vector{T}}(undef, n)
    @inbounds fadjlist[1] = Vector{T}(2:n)
    @inbounds badjlist[1] = T[]
    @inbounds fadjlist[2] = T[3]
    @inbounds badjlist[2] = T[1, n]
    @inbounds fadjlist[n] = T[2]
    @inbounds badjlist[n] = T[1, n - 1]

    @inbounds @simd for u = 3:(n-1)
        fadjlist[u] = T[u + 1]
        badjlist[u] = T[1, u - 1]
    end
    return SimpleDiGraph(ne, fadjlist, badjlist)
end

"""
    Grid(dims; periodic=false)

Create a ``|dims|``-dimensional cubic lattice, with length `dims[i]`
in dimension `i`.

### Optional Arguments
- `periodic=false`: If true, the resulting lattice will have periodic boundary
condition in each dimension.
"""
function Grid(dims::AbstractVector{T}; periodic=false) where {T <: Integer}
    # checks if T is large enough for product(dims)
    Tw = widen(T)
    n = one(T)
    for d in dims
        d <= 0 && return SimpleGraph{T}(0)
        nw = Tw(n) * Tw(d)
        n = T(nw)
    end

    if periodic
        g = CycleGraph(dims[1])
        for d in dims[2:end]
            g = cartesian_product(CycleGraph(d), g)
        end
    else
        g = PathGraph(dims[1])
        for d in dims[2:end]
            g = cartesian_product(PathGraph(d), g)
        end
    end
    return g
end

"""
    BinaryTree(k::Integer)

Create a [binary tree](https://en.wikipedia.org/wiki/Binary_tree)
of depth `k`.
"""
function BinaryTree(k::T) where {T <: Integer}
    k <= 0 && return SimpleGraph(0)
    k == 1 && return SimpleGraph(1)
    Tw = widen(T)
    n = T(Tw(2)^Tw(k) - Tw(1))  # checks if T is large enough for 2^k

    ne = Int(n - 1)
    fadjlist = Vector{Vector{T}}(undef, n)
    @inbounds fadjlist[1] = T[2, 3]
    @inbounds for i in 1:(k - 2)
        @simd for j in (2^i):(2^(i + 1) - 1)
            fadjlist[j] = T[j ÷ 2, 2j, 2j + 1]
        end
    end
    i = k - 1
    @inbounds @simd for j in (2^i):(2^(i + 1) - 1)
        fadjlist[j] = T[j ÷ 2]
    end
    return SimpleGraph(ne, fadjlist)
end

"""
    BinaryTree(k::Integer)

Create a double complete binary tree with `k` levels.

### References
- Used as an example for spectral clustering by Guattery and Miller 1998.
"""
function DoubleBinaryTree(k::Integer)
    gl = BinaryTree(k)
    gr = BinaryTree(k)
    g = blockdiag(gl, gr)
    add_edge!(g, 1, nv(gl) + 1)
    return g
end


"""
    RoachGraph(k)

Create a Roach Graph of size `k`.

### References
- Guattery and Miller 1998
"""
function RoachGraph(k::Integer)
    dipole = CompleteGraph(2)
    nopole = SimpleGraph(2)
    antannae = crosspath(k, nopole)
    body = crosspath(k, dipole)
    roach = blockdiag(antannae, body)
    add_edge!(roach, nv(antannae) - 1, nv(antannae) + 1)
    add_edge!(roach, nv(antannae), nv(antannae) + 2)
    return roach
end


"""
    CliqueGraph(k, n)

Create a graph consisting of `n` connected `k`-cliques.
"""
function CliqueGraph(k::T, n::T) where {T <: Integer}
    Tw = widen(T)
    knw = Tw(k) * Tw(n)
    kn = T(knw)  # checks if T is large enough for k * n

    g = SimpleGraph(kn)
    for c = 1:n
        for i = ((c - 1) * k + 1):(c * k - 1), j = (i + 1):(c * k)
            add_edge!(g, i, j)
        end
    end
    for i = 1:(n - 1)
        add_edge!(g, (i - 1) * k + 1, i * k + 1)
    end
    add_edge!(g, 1, (n - 1) * k + 1)
    return g
end