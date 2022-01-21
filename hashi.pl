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

vizinhas([], _, []).
%TODO: Eliminar ilhas que estão entre duas ilhas, 
%atm está a marcá las como vizinhas

%Caso de pertencerem ah mesma linha
vizinhas([Eilha | RIlhas], Ilha, [IlhaVizinha | RVizinhas]) :- 
  obter_linha_ilha(Ilha, Ilha_linha),
  obter_linha_ilha(Eilha, Eilha_linha),
  Ilha_linha = Eilha_linha,
  IlhaVizinha = Eilha,
  vizinhas(RIlhas, Ilha, RVizinhas).

%Brainstorm:
%Como ver se duas ilhas não são vizinhas, mas partilham a mesma coluna ou linha?
%
%
%
%
%Caso de pertenceram ah mesma coluna
vizinhas([Eilha | RIlhas], Ilha, [IlhaVizinha | RVizinhas]) :- 
  obter_col_ilha(Ilha, Ilha_col),
  obter_col_ilha(Eilha, Eilha_col),
  Ilha_col = Eilha_col,
  IlhaVizinha = Eilha,
  vizinhas(RIlhas, Ilha, RVizinhas).

%Caso em que nao sao vizinhas
vizinhas([_ | RIlhas], Ilha, [_ | RVizinhas]) :-
  vizinhas(RIlhas, Ilha, RVizinhas).


%----------
%Codigo Auxiliar
%----------

%Construtor e seletores da estrutura Ilha
faz_ilha(N, N_Linha, N_Col, ilha(N, (N_Linha, N_Col))).

obter_linha_ilha(ilha(_, (N_Linha, _)), N_Linha).

obter_col_ilha(ilha(_, (_, N_Col)), N_Col).

obter_nr_pontes_ilha(ilha(N, (_, _)), N).

%----------

%Devolve q