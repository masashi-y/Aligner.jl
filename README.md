# Aligner.jl
perform alignment based on edit distance

    julia> using Aligner
    
    julia> source = split("i played in the jazz combo all four years", " ");
    
    julia> target = split("i played in the jazz calm bowl all four years", " ");
    
    julia> align(source, target, 1, 1, 2);
    
    julia> println(res.source)
    SubString{ASCIIString}["N","i","played","in","the","jazz","combo","all","four","years"]
    
    julia> println(res.target)
    SubString{ASCIIString}["i","played","in","the","jazz","calm","bowl","all","four","years"]
    
You can define some binary cost function and pass to align function

    julia> d(s,t) = generic_edit_distance(s, t, 1, 1, (x,y)-> x == y ? 0 : 1) / max(length(s), length(t))
    d (generic function with 1 method)
    
    julia> res = align(source, target, 1, 1, d);
    
    julia> println(res.source)
    SubString{ASCIIString}["i","played","in","the","jazz","N","combo","all","four","years"]
    
    julia> println(res.target)
    SubString{ASCIIString}["i","played","in","the","jazz","calm","bowl","all","four","years"]

Alignment can be made between two Vector (one-dimensinoal Array) of any types,
if you define Aligner.null function for aligned items.

    julia> type Word
               str
           end

    julia> source = split("i played in the jazz combo all four years", " ");

    julia> source = map(Word, source);

    julia> target = split("i played in the jazz calm bowl all four years", " ");

    julia> Base.length(w::Word) = length(w.str);

    julia> d(s::Word,t::AbstractString) = Aligner.generic_edit_distance(s.str, t, 1, 1, (x,y)-> x == y ? 0 : 1) / max(length(s), length(t))
    d (generic function with 1 method)

    julia> Aligner.null(Word) = Word("NULL");

    julia> res = align(source, target, 1, 1, d);

    julia> println(res.source)
    [Word("i"),Word("played"),Word("in"),Word("the"),Word("jazz"),Word("NULL"),Word("combo"),Word("all"),Word("four"),Word("years")]

    julia> println(res.target)
    SubString{ASCIIString}["i","played","in","the","jazz","calm","bowl","all","four","years"]


As can be seen in the result, Aligner.null function is called to fill in null token,
in this example it means that "calm" in target has no correspondence.
#### Reference
[Levenshtein distance/Alignment - Rosetta Code:][https://rosettacode.org/wiki/Levenshtein_distance/Alignment]
