-module (matrix_mult).
-export ([start/2, rowmult/7, proc_mmult/8]).
-import(lists, [reverse/1]).

sumprod(0, _, _, Sum, _, _) -> Sum;
sumprod(I, C, R, Sum, M1, M2) -> 
    %io:format ("~w ~w ~w~n", [I, C, R]),
    NewSum = Sum + (element(round(I), element(round(R),M1)) * element(round(C),element(round(I),M2))),
    sumprod(I-1, C, R, NewSum, M1, M2).

rowmult(PID, _, 0, _, L, _, _) -> PID ! list_to_tuple(L);
rowmult(PID, I, C, R, L, M1, M2) -> 
    SumProd = sumprod(I, C, R, 0, M1, M2),
    rowmult(PID, I, C-1, R, [SumProd|L], M1, M2).

proc_mmult (PID, I, C, R, M1, M2, StartRow, EndRow) when StartRow < EndRow ->
    rowmult (PID, I, C, StartRow, [], M1, M2),
    proc_mmult (PID, I, C, R, M1, M2, StartRow+1, EndRow);
proc_mmult (_PID, _I, _C, _R, _M1, _M2, _StartRow, _EndRow) ->
    ok.

mmult(PID, I, C, R, M1, M2, N, M) ->
    create_threads (PID, I, C, R, M1, M2, N, M, 0).

%    rowmult(I, C, R, [], M1, M2),
%    mmult(PID, I, C, R-1, [NewRow|MM], M1, M2).

mmult(M1, M2, N, M) -> 
    Inner = size(M2), 
    NRows = size(M1), 
    mmult (self(), Inner, NRows, NRows, M1, M2, N, M),
    wait([], N).

%   matrix_mult (j*n/m, (((j+1)*n)/m));

create_threads (_PID, _I, _C, _R, _M1, _M2, _N, M, J) when M == J ->
    ok;
create_threads (PID, I, C, R, M1, M2, N, M, J) ->
    spawn (matrix_mult, proc_mmult, [PID, I, C, R, M1, M2, round(J*N/M)+1, round(((J+1)*N)/M)+1]),
    create_threads (PID, I, C, R, M1, M2, N, M, J+1).

wait (Matrix, 0) -> Matrix;
wait (Matrix, N) ->
    receive 
        NewRow ->
            wait([NewRow | Matrix], N-1)
    end.

start (N, M) ->
    M1 = mkmatrix(N, N),
    M2 = mkmatrix(N, N),
    io:format("Threads : ~w~nRows/Columns : ~w~n", [M, N]),
    {StartMega, StartSec, StartMicro} = now(),
    MM = mmult(M1, M2, N, M),
    {EndMega, EndSec, EndMicro} = now(),
    Time = (EndMega * 1000000000000   + EndSec * 1000000   + EndMicro) -
        (StartMega * 1000000000000 + StartSec * 1000000 + StartMicro),    
    io:format("Time in microseconds:  ~p~n", [Time]).
    %[io:format ("~w~n", [X]) || X <- MM].

mkrow(0, L, Count) -> {list_to_tuple(reverse(L)), Count};
mkrow(N, L, Count) -> mkrow(N-1, [Count|L], Count+1).

mkmatrix(0, _, _, M) -> list_to_tuple(reverse(M));
mkmatrix(NR, NC, Count, M) ->
    {Row, NewCount} = mkrow(NC, [], Count),
    mkmatrix(NR-1, NC, NewCount, [Row|M]).

mkmatrix(NR, NC) -> mkmatrix(NR, NC, 1, []).

