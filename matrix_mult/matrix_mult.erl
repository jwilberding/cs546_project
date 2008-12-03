-module (matrix_mult).
-export ([start/0]).
-import(lists, [reverse/1]).

sumprod(0, _, _, Sum, _, _) -> Sum;
sumprod(I, C, R, Sum, M1, M2) -> 
    NewSum = Sum + (element(I,element(R,M1)) * element(C,element(I,M2))),
    sumprod(I-1, C, R, NewSum, M1, M2).

rowmult(_, 0, _, L, _, _) -> list_to_tuple(L);
rowmult(I, C, R, L, M1, M2) -> 
    SumProd = sumprod(I, C, R, 0, M1, M2),
    rowmult(I, C-1, R, [SumProd|L], M1, M2).

mmult(_, _, 0, MM, _, _) -> list_to_tuple(MM);
mmult(I, C, R, MM, M1, M2) ->
    NewRow = rowmult(I, C, R, [], M1, M2),
    mmult(I, C, R-1, [NewRow|MM], M1, M2).

mmult(M1, M2) -> 
    Inner = size(M2), 
    NRows = size(M1), 
    mmult(Inner, NRows, NRows,[], M1, M2).

start () ->
    Size = 10,
    M1 = mkmatrix(Size, Size),
    M2 = mkmatrix(Size, Size),
    MM = mmult(M1, M2),
    io:format ("~w~n", [MM]).

mkrow(0, L, Count) -> {list_to_tuple(reverse(L)), Count};
mkrow(N, L, Count) -> mkrow(N-1, [Count|L], Count+1).

mkmatrix(0, _, _, M) -> list_to_tuple(reverse(M));
mkmatrix(NR, NC, Count, M) ->
    {Row, NewCount} = mkrow(NC, [], Count),
    mkmatrix(NR-1, NC, NewCount, [Row|M]).

mkmatrix(NR, NC) -> mkmatrix(NR, NC, 1, []).

