% Rafael Girao, ist199309

:- [codigo_comum].
:- [puzzles_publicos].
%----------
%2.1 - Predicado extrai_ilhas_linha/3
%----------

extrai_ilha_linha(N_Linha, Linha, ilha(N_Pontes, (N_Linha, N_Col))) :-
  nth1(N_Col, Linha, N_Pontes),
  N_Pontes =\= 0.

extrai_ilhas_linha(N_Linha, Linha, Ilhas) :-
  findall(Ilha, extrai_ilha_linha(N_Linha, Linha, Ilha), Ilhas).

%----------
%2.2 - ilhas/2
%----------

ilhas_linha(Puz, IlhasLinha) :-
  nth1(N_Linha, Puz, Linha_Puzzle),
  extrai_ilhas_linha(N_Linha, Linha_Puzzle, IlhasLinha).

ilhas(Puz, Ilhas) :-
  findall(IlhasLinha, ilhas_linha(Puz, IlhasLinha), ListaAninhadaIlhas),
  flatten(ListaAninhadaIlhas, Ilhas).

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

