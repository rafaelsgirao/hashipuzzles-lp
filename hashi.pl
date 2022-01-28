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
posicao_entre((Linha1, Col1), (Linha2, Col2), (Linha1, Coluna)) :-
  Linha1 =:= Linha2,
  !,
  Min is min(Col1, Col2),
  Max is max(Col1, Col2),

  SegundaCol is +(Min, 1),
  PenultimaCol is -(Max, 1),

  between(SegundaCol, PenultimaCol, Coluna).

posicao_entre((Linha1, Col1), (Linha2, Col2), (Linha, Col1)) :-
  Col1 =:= Col2,
  !,
  Min is min(Linha1, Linha2),
  Max is max(Linha1, Linha2),

  SegundaLinha is +(Min, 1),
  PenultimaLinha is -(Max, 1),

  between(SegundaLinha, PenultimaLinha, Linha).

posicao_entre((_, _), (_, _), _) :-
  fail.

posicoes_entre(Pos1, Pos2, Posicoes) :-
  bagof(Posicao, posicao_entre(Pos1, Pos2, Posicao), Posicoes).

%TODO: Criar um predicado auxiliar ordena_posicoes, que recebe
%Duas posicoes e retorna-as numa lista, ordenadas.

%FIXME: this predicate is horrible.
%FIXME: move this predicate to end of file

ordena_posicoes((Linha1, Col1), (Linha2, Col2), [PosMenor, PosMaior]) :-
  Linha1 < Linha2,
  !,
  PosMenor = (Linha1, Col1),
  PosMaior = (Linha2, Col2).

ordena_posicoes((Linha1, Col1), (Linha2, Col2), [PosMenor, PosMaior]) :-
  Linha1 > Linha2,
  !,
  PosMenor = (Linha2, Col2),
  PosMaior = (Linha1, Col1).

ordena_posicoes((Linha1, Col1), (Linha2, Col2), [PosMenor, PosMaior]) :-
  Linha1 =:= Linha2,
  Col1 < Col2,
  !,
  PosMenor = (Linha1, Col1),
  PosMaior = (Linha2, Col2).

ordena_posicoes((Linha1, Col1), (Linha2, Col2), [PosMenor, PosMaior]) :-
  Linha1 =:= Linha2,
  Col1 > Col2,
  !,
  PosMenor = (Linha2, Col2),
  PosMaior = (Linha1, Col1).


%----------
%2.6 - cria_ponte/3
%----------
cria_ponte(Pos1, Pos2, ponte(PosMenor, PosMaior)) :-
  ordena_posicoes(Pos1, Pos2, [PosMenor, PosMaior]).


%----------
%2.7 - caminho_livre/5
%----------

%Duas ilhas deixam de ser vizinhas,
%apos a criação de ponte(Pos1, Pos2), sse:
% - Essa ponte nao for entre as duas ilhas;
% - Pelo menos uma das posicoes entre as duas ilhas for ocupada pela ponte.

caminho_livre(Pos1, Pos2, _, ilha(_, Pos_I), ilha(_, Pos_Vz)) :-
  ordena_posicoes(Pos1, Pos2, [MenorPos1, MaiorPos1]),
  ordena_posicoes(Pos_I, Pos_Vz, [MenorPos2, MaiorPos2]),
  MenorPos1 == MenorPos2,
  MaiorPos1 == MaiorPos2,
  !.

caminho_livre(_, _, PosicoesPonte, ilha(_, Pos_I), ilha(_, Pos_Vz)) :-
  member(Posicao, PosicoesPonte),
  posicoes_entre(Pos_I, Pos_Vz, PosicoesIlhaVz),
  member(Posicao, PosicoesIlhaVz),
  !,
  fail.


%----------
%2.8 - actualiza_vizinhas_entrada/5
%----------
%Sample entrada: [ilha(3,(1,7)),[ilha(4,(1,1)),ilha(2,(6,7))],[]]
actualiza_vizinha_entrada(Pos1, Pos2, Posicoes, [Ilha, Vizinhas, _], Vizinha) :-
  member(Vizinha, Vizinhas),
  caminho_livre(Pos1, Pos2, Posicoes, Ilha, Vizinha).

actualiza_vizinhas_entrada(Pos1, Pos2, Posicoes, [Ilha, Vizinhas, Pontes], [Ilha, NovasVizinhas, Pontes]) :-
  findall(Vizinha, actualiza_vizinha_entrada(Pos1, Pos2, Posicoes, [Ilha, Vizinhas, Pontes], Vizinha), NovasVizinhas).

%----------
%2.9 - actualiza_vizinhas_apos_pontes/4
%----------
actualiza_vizinha_apos_pontes(Estado, Pos1, Pos2, Posicoes, EntradaNova) :-
  member(Entrada, Estado),
  actualiza_vizinhas_entrada(Pos1, Pos2, Posicoes, Entrada, EntradaNova).

actualiza_vizinhas_apos_pontes(Estado, Pos1, Pos2, NovoEstado) :-
  posicoes_entre(Pos1, Pos2, Posicoes),
  findall(EntradaNova, actualiza_vizinha_apos_pontes(Estado, Pos1, Pos2, Posicoes, EntradaNova), NovoEstado).
%----------
%2.10 - ilhas_terminadas/2
%----------
%TODO: Ver o que significa 'esta ilha está terminada se N_pontes for diferente de X'
ilha_terminada(Estado, ilha(N_pontes, Posicao)) :-
  member([ilha(N_pontes, Posicao), _, Pontes], Estado),
  number(N_pontes),
  length(Pontes, N_pontes).

ilhas_terminadas(Estado, Ilhas_term) :-
  findall(Ilha_term, ilha_terminada(Estado, Ilha_term), Ilhas_term).

%----------
%2.11 - tira_ilhas_terminadas_entrada/3
%----------
%TODO: averiguar se preciso do termo 'Ilha' aqui - prolly not, but better safe than sorry
tira_ilha_terminada_entrada_aux(Ilhas_term, Vizinhas, IlhaVizinha) :-
  member(IlhaVizinha, Vizinhas),
  \+ member(IlhaVizinha, Ilhas_term).
%  member(IlhaVizinha, NovaVizinhas).

tira_ilhas_terminadas_entrada(Ilhas_term, [Ilha, Vizinhas, Pontes], [Ilha, NovaVizinhas, Pontes]) :-
  findall(IlhaVizinha, tira_ilha_terminada_entrada_aux(Ilhas_term, Vizinhas, IlhaVizinha), NovaVizinhas).

%----------
%2.12 - tira_ilhas_terminadas/3
%----------
tira_ilhas_terminadas_aux(Estado, Ilhas_term, Nova_entrada) :-
  member(Entrada, Estado),
  tira_ilhas_terminadas_entrada(Ilhas_term, Entrada, Nova_entrada).
%  member(NovaEntrada, Novo_estado).

tira_ilhas_terminadas(Estado, Ilhas_term, Novo_estado) :-
  findall(Nova_entrada, tira_ilhas_terminadas_aux(Estado, Ilhas_term, Nova_entrada), Novo_estado).
%----------
%2.13 - tira_ilhas_terminadas_entrada/3
%----------
%TODO: perguntar se este corte é sempre válido 
% ou se preciso de ter um \+ member(...) dentro da 2ª definição
marca_ilhas_terminadas_entrada(Ilhas_term, [ilha(N_pontes, Pos), Vizinhas, Pontes], [ilha('X', Pos), Vizinhas, Pontes]) :-
  member(ilha(N_pontes, Pos), Ilhas_term),
  !.

marca_ilhas_terminadas_entrada(_, Entrada, Entrada).
%----------
%2.14 - marca_ilhas_terminadas/3
%----------
marca_ilhas_terminadas_aux(Estado, Ilhas_term, Nova_entrada) :-
  member(Entrada, Estado),
  marca_ilhas_terminadas_entrada(Ilhas_term, Entrada, Nova_entrada).

marca_ilhas_terminadas(Estado, Ilhas_term, Novo_estado) :-
  findall(Nova_entrada, marca_ilhas_terminadas_aux(Estado, Ilhas_term, Nova_entrada), Novo_estado).



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

