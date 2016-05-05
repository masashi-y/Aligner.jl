# Aligner.jl
perform alignment based on edit distance
[Levenshtein distance/Alignment - Rosetta Code:][https://rosettacode.org/wiki/Levenshtein_distance/Alignment]

    julia> using Aligner
    
    julia> source = split("i played in the jazz combo all four years", " ");
    
    julia> target = split("i played in the jazz calm bowl all four years", " ");
    
    julia> align(source, target, 1, 1, 2);
    
    julia> println(res.source)
    SubString{ASCIIString}["N","i","played","in","the","jazz","combo","all","four","years"]
    
    julia> println(res.target)
    SubString{ASCIIString}["i","played","in","the","jazz","calm","bowl","all","four","years"]
    
    julia> d(s,t) = generic_edit_distance(s, t, 1, 1, (x,y)-> x == y ? 0 : 1) / max(length(s), length(t))
    d (generic function with 1 method)
    
    julia> res = align(source, target, 1, 1, d);
    
    julia> println(res.source)
    SubString{ASCIIString}["i","played","in","the","jazz","N","combo","all","four","years"]
    
    julia> println(res.target)
    SubString{ASCIIString}["i","played","in","the","jazz","calm","bowl","all","four","years"]

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
