module Aligner

export align,
       levenshtein,
       generic_edit_distance,
       Alignment,
       null

type Alignment
    source_to_target
    target_to_source
    source
    target
    mat
end

null(::Type{Char}) = '-'
null{S<:AbstractString}(::Type{S}) = S("N")
null{S<:AbstractString}(::Type{SubString{S}}) = S("N")

cost_func(cost) = (x, y) -> cost
equality(cost) = (x, y) -> x == y ? 0 : cost

function generic_distance_matrix{A,B}(
    seq1::Vector{A},
    seq2::Vector{B},
    ins_cost::Function,
    del_cost::Function,
    sub_cost::Function
)
    seq1len = length(seq1)
    seq2len = length(seq2)
    len = max(seq1len, seq2len)

    d_type = typeof(promote(map(f->f(seq1[1], seq2[1]),
        [ins_cost, del_cost, sub_cost])...)[1])
    d = zeros(d_type, seq1len+1, seq2len+1)
    d[:,1] = 0:seq1len
    d[1,:] = 0:seq2len

    for i = 2:seq1len+1, j = 2:seq2len+1
        ins = j < 3 ? 1 : ins_cost(seq1[i-1], seq2[j-2])
        del = i < 3 ? 1 : del_cost(seq1[i-2], seq2[j-1])
        # ins = ins_cost(seq1[i-1], seq2[j-1])
        # del = del_cost(seq1[i-1], seq2[j-1])
        sub = sub_cost(seq1[i-1], seq2[j-1])
        d[i,j] = min(d[i-1,j]+ins, d[i,j-1]+del, d[i-1,j-1]+sub)
    end
    d
end

function generic_distance_matrix{A,B,C<:Real}(
    seq1::Vector{A},
    seq2::Vector{B},
    ins_cost::C,
    del_cost::C,
    sub_cost::C
)
    generic_distance_matrix(seq1, seq2, cost_func(ins_cost), cost_func(del_cost), equality(sub_cost))
end

function generic_distance_matrix{A,B,C<:Real}(
    seq1::Vector{A},
    seq2::Vector{B},
    ins_cost::C,
    del_cost::C,
    sub_cost::Function
)
    generic_distance_matrix(seq1, seq2, cost_func(ins_cost), cost_func(del_cost), sub_cost)
end

function generic_distance_matrix{S<:AbstractString,T<:AbstractString}(
    seq1::S, seq2::T, ins_cost, del_cost, sub_cost)
    generic_distance_matrix(collect(seq1), collect(seq2),
        ins_cost, del_cost, sub_cost)
end


# levenshtein edit distance in which costs are (ins, del, sub) == (1, 1, 2)
levenshtein(seq1, seq2) = generic_distance_matrix(seq1, seq2, 1, 1, 2)[end, end]

generic_edit_distance(seq1, seq2, ins, del, sub) = generic_distance_matrix(seq1, seq2, ins, del, sub)[end, end]

function align{A,B}(
    seq1::Vector{A},
    seq2::Vector{B},
    ins_cost::Function,
    del_cost::Function,
    sub_cost::Function
)
    mat = generic_distance_matrix(seq1, seq2, ins_cost, del_cost, sub_cost)
    res1 = similar(seq1, 0)
    res2 = similar(seq2, 0)
    idx1 = Int[]
    idx2 = Int[]
    i = size(mat, 1); j = size(mat, 2)
    while true
        i <= 1 && j <= 1 && break
        if i > 1 && j > 1 && mat[i,j] == mat[i-1,j-1] + sub_cost(seq1[i-1], seq2[j-1])
            i -= 1; j -= 1
            push!(idx1, j)
            push!(idx2, i)
            push!(res1, seq1[i])
            push!(res2, seq2[j])
        elseif i > 1 && mat[i,j] == mat[i-1,j] + (j == size(mat, 2) ? 1 : ins_cost(seq1[i-1], seq2[j]) )
            i -= 1
            push!(idx1, 0)
            push!(idx2, i)
            push!(res1, seq1[i])
            push!(res2, null(B))
        elseif j > 1 && mat[i,j] == mat[i,j-1] + (i == size(mat, 1) ? 1 : del_cost(seq1[i], seq2[j-1]) )
            j -= 1
            push!(idx1, j)
            push!(idx2, 0)
            push!(res1, null(A))
            push!(res2, seq2[j])
        end
    end
    Alignment(reverse!(idx1), reverse!(idx2), reverse!(res1), reverse!(res2), mat)
end

function align{A,B,C<:Real}(
    seq1::Vector{A},
    seq2::Vector{B},
    ins_cost::C,
    del_cost::C,
    sub_cost::C
)
    align(seq1, seq2, cost_func(ins_cost), cost_func(del_cost), equality(sub_cost))
end

function align{A,B,C<:Real}(
    seq1::Vector{A},
    seq2::Vector{B},
    ins_cost::C,
    del_cost::C,
    sub_cost::Function
)
    align(seq1, seq2, cost_func(ins_cost), cost_func(del_cost), sub_cost)
end


# for debugging
function printmat(m)
    mat = map(x-> @sprintf("%1.2f", x), m)
    for i = 1:size(m, 1)
        for j = 1:size(m, 2)
            print(mat[i,j], " ")
        end
        println()
    end
end


end # module
