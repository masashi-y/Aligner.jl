# Aligner.jl
perform alignment based on edit distance

Aligner.jl exports following functions:
* align(source, target, ins, del, sub)
* generic_edit_distance(source, target, ins, del, sub)
* levenshtein(source, target)
* Alignment
* null(::Type{})

where ins, del, sub arguments are the real valued (some T s.t. T<:Real) costs
for insertion, deletion and substitution.  
these argements can also be some binary function; the detail is given in Usage.

`levenshtein` calculates levenshtein edit distance, which actually is implemented as  
`generic_edit_distance(source, target, 1, 1, 1)`.

# Usage
    julia> using Aligner

    julia> source = collect("rosettacode"); target = collect("raisethysword"); # converting to Array{Char}

    julia> res = align(source, target, 1, 1, 1); # all the insertion, deletion, substitution costs are 1.

    julia> println(convert(ASCIIString, res.source))
    r-oset-tacode

    julia> println(convert(ASCIIString, res.target))
    raisethysword

`align` function returns `Alignment` type object with five fields;  
* `source`, `target` as shown in the example
* `source_to_target`, `target_to_source`, which encode information such as
Nth element in the source corresponds to Mth element in the target
* `mat`, which is 2-dimensional matrix used to calculate edit distance

You can define some binary cost function and pass to `align` function

    julia> println(source, "\n", target)
    SubString{ASCIIString}["i","played","in","the","jazz","combo","all","four","years"]
    SubString{ASCIIString}["i","played","in","the","jazz","calm","bowl","all","four","years"]

    julia> normalized_levenshtein(s,t) = levenshtein(s, t) / max(length(s), length(t))
    normalized_levenshtein (generic function with 1 method)

    julia> res = align(source, target, 1, 1, normalized_levenshtein);

    julia> println(res.source, "\n", res.target)
    SubString{ASCIIString}["i","played","in","the","jazz","N","combo","all","four","years"]
    SubString{ASCIIString}["i","played","in","the","jazz","calm","bowl","all","four","years"]

Alignment can be made between two `Vector`s (one-dimensinoal `Array`) of any types,  
if you define `Aligner.null` function for the aligned types.

    julia> type Word
               str
           end

    julia> Aligner.null(Word) = Word("NULL");

    julia> source = split("i played in the jazz combo all four years", " ");

    julia> source = map(Word, source);

    julia> target = split("i played in the jazz calm bowl all four years", " ");

    julia> normalized_levenshtein(s::Word,t::AbstractString) = levenshtein(s.str, t) / max(length(s.str), length(t))
    normalized_levenshtein (generic function with 2 method)

    julia> res = align(source, target, 1, 1, normalized_levenshtein);

    julia> println(res.source, "\n", res.target)
    [Word("i"),Word("played"),Word("in"),Word("the"),Word("jazz"),Word("NULL"),Word("combo"),Word("all"),Word("four"),Word("years")]
    SubString{ASCIIString}["i","played","in","the","jazz","calm","bowl","all","four","years"]


As can be seen in the result, `Aligner.null` function is called to fill in null token,  
in this example it means that "calm" in target has no correspondence in the source.

#### Reference
[Levenshtein distance/Alignment - Rosetta Code:](https://rosettacode.org/wiki/Levenshtein_distance/Alignment)
