
using Aligner

rawsent1 = "i played in the jazz combo all four years"
rawsent2 = "i played in the jazz calm bowl all four years"

sent1 = split(rawsent1, " ")
sent2 = split(rawsent2, " ")

mat = generic_distance_matrix(sent1, sent2, 1, 1, normalized_word_distance)
printmat(mat)

alignment = align(sent1, sent2, 1, 1, normalized_word_distance)
println(alignment.res1)
println(alignment.res2)
printmat(alignment.mat)
println(alignment.idx1)
