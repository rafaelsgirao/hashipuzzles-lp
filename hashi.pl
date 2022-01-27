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
%FIXME: 2ª condição para as ilhas serem vizinhas não está a ser cumprida
%FIXME: Ilhas vizinhas não estão a sair por ordem

%Caso de pertencerem ah mesma coluna
vizinha(Ilhas, ilha(_, (N_Linha, N_Col)), ilha(N_Pontes_e, (N_Linha_e, N_Col_e))) :-
  member(ilha(N_Pontes_e, (N_Linha_e, N_Col_e)), Ilhas),
  N_Linha == N_Linha_e,
  N_Col \== N_Col_e. % Nao retornar a propria ilha

%Caso de pertencera ah mesma linha
vizinha(Ilhas, ilha(_, (N_Linha, N_Col)), ilha(N_Pontes_e, (N_Linha_e, N_Col_e))) :-
  member(ilha(N_Pontes_e, (N_Linha_e, N_Col_e)), Ilhas),
  N_Linha \== N_Linha_e, % Nao retornar a propria ilha
  N_Col == N_Col_e. 

vizinhas(Ilhas, Ilha, Vizinhas) :-
  findall(IlhaVizinha, vizinha(Ilhas, Ilha, IlhaVizinha), Vizinhas).


%----------
%2.4 - estado/2
%----------

estado_singular(Ilhas, [Ilha, Vizinhas, []]) :-
  member(Ilha, Ilhas),
  vizinhas(Ilhas, Ilha, Vizinhas).


estado(Ilhas, Estado) :-
  findall(EstadoIlha, estado_singular(Ilhas, EstadoIlha), Estado).

%----------
%2.5 - posicoes_entre/3
%----------

%----------
%2.6 - cria_ponte/3
%----------

%----------
%2.7 - caminho_livre/5
%----------

%----------
%2.8 - actualiza_vizinhas_entrada/5
%----------

%----------
%2.9 - actualiza_vizinhas_apos_pontes/4
%----------

%----------
%2.10 - ilhas_terminadas/2
%----------

%----------
%2.11 - tira_ilhas_terminadas_entrada/3
%----------

%----------
%2.12 - tira_ilhas_terminadas/3
%----------

%----------
%2.13 - tira_ilhas_terminadas_entrada/3
%----------

%----------
%2.14 - marca_ilhas_terminadas/3
%----------

%----------
%2.15 - trata_ilhas_terminadas/2
%----------

%----------
%2.16 - junta_pontes/5
%----------








%----------
%Codigo Auxiliar
%----------

%Construtor e seletores da estrutura Ilha
faz_ilha(N, N_Linha, N_Col, ilha(N, (N_Linha, N_Col))).

obter_linha_ilha(ilha(_, (N_Linha, _)), N_Linha).

obter_col_ilha(ilha(_, (_, N_Col)), N_Col).

obter_nr_pontes_ilha(ilha(N, (_, _)), N).

%----------

