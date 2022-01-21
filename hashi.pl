% Rafael Girao, ist199309

:- [codigo_comum].
:- [puzzles_publicos].
%----------
%2.1 - Predicado extrai_ilhas_linha/3
%----------

%extrai_ilhas_linha/3, enunciado
%---

extrai_ilhas_linha(_, [], []).

extrai_ilhas_linha(N_L, Linha, Ilhas) :-
  extrai_ilhas_linha(N_L, 1, Linha, Ilhas).

%extrai_ilhas_linha/4 , auxiliar
%---
extrai_ilhas_linha(_, _, [], []) :- !.

%Caso o nº de pontes seja 0, passar a frente
extrai_ilhas_linha(N_L, N_Col, [0 | B], Ilhas) :-
  Col_seguinte is  +(N_Col,1),
  extrai_ilhas_linha(N_L, Col_seguinte , B, Ilhas).

extrai_ilhas_linha(N_L, N_Col, [N_Pontes | B], [Nova_ilha | Ilhas]) :-
  % number(N_Pontes), %TODO: check if necessary
  N_Pontes =\= 0,
  Col_seguinte is +(N_Col,1) ,
  faz_ilha(N_Pontes, N_L, N_Col, Nova_ilha),
  extrai_ilhas_linha(N_L, Col_seguinte, B, Ilhas).

%----------
%2.2 - ilhas/2
%----------

ilhas(Puz, Ilhas) :- 
  ilhas(1, Puz, ListaAninhadaIlhas),
  flatten(ListaAninhadaIlhas, Ilhas).


%ilhas/3, auxiliar
ilhas(_, [], _).

ilhas(N_L, [LinhaPuzzle | CPuz], [LinhaIlhas | CIlhas]) :-
  Proximalinha is +(N_L, 1),
  extrai_ilhas_linha(N_L, LinhaPuzzle, LinhaIlhas),
  ilhas(Proximalinha, CPuz, CIlhas).

%----------
%2.3 - vizinhas/3
%----------

vizinhas(Ilhas, Ilha, Vizinhas) : 
%----------
%Codigo Auxiliar
%----------

%Construtor da estrutura Ilha
faz_ilha(N, N_Linha, N_Col, ilha(N, (N_Linha, N_Col))).

obter_linha_ilha(ilha(N, (N_Linha, N_Col)), N_Linha).

obter_linha_ilha(ilha(N, (N_Linha, N_Col)), N_Col).

obter_nr_pontes_ilha(ilha(N, (N_Linha, N_Col)), N).