% Rafael Girao, ist199309

:- [codigo_comum].
%:- [puzzles_publicos].

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


%Funcao auxiliar para satisfazer a 2a condicao de vizinhas/3
%TODO: perguntar se posso usar um predicado feito muito mais ah frente
%para definir este
vizinha_aux(Ilhas, ilha(_, Pos1), ilha(_), Pos2) :-
  member(ilha(_, Pos3), Ilhas),
  posicoes_entre(Pos1, Pos2, Posicoes),
  member(Pos3, Posicoes).
  
%vizinhas_aux(Ilhas, Ilha1, Ilha2) :-
%  forall()
  
%----------
%2.3 - vizinhas/3
%----------
%FIXME: 2a condicao para as ilhas serem vizinhas nao estah a ser cumprida

%Caso de pertencera ah mesma linha
vizinha(Ilhas, ilha(_, (N_Linha, N_Col)), ilha(N_Pontes_e, (N_Linha_e, N_Col_e))) :-
  member(ilha(N_Pontes_e, (N_Linha_e, N_Col_e)), Ilhas),
  N_Linha =\= N_Linha_e, % Nao retornar a propria ilha
  N_Col =:= N_Col_e.
 % \+ vizinhas_aux(Ilhas, ilha(_, (N_Linha, N_Col), ilha()).

%Caso de pertencerem ah mesma coluna
vizinha(Ilhas, ilha(_, (N_Linha, N_Col)), ilha(N_Pontes_e, (N_Linha_e, N_Col_e))) :-
  member(ilha(N_Pontes_e, (N_Linha_e, N_Col_e)), Ilhas),
  N_Linha =:= N_Linha_e,
  N_Col =\= N_Col_e. % Nao retornar a propria ilha


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
  !,
  fail.

posicoes_entre(Pos1, Pos2, Posicoes) :-
  bagof(Posicao, posicao_entre(Pos1, Pos2, Posicao), Posicoes).

%TODO: Criar um predicado auxiliar ordena_posicoes, que recebe
%Duas posicoes e retorna-as numa lista, ordenadas.

%FIXME: this predicate is horrible.
%FIXME: move this predicate to end of file

ordena_posicoes((Linha1, Col1), (Linha2, Col2), [(Linha1, Col1), (Linha2, Col2)]) :-
  Linha1 < Linha2,
  !.

ordena_posicoes((Linha1, Col1), (Linha2, Col2), [(Linha2, Col2), (Linha1, Col1)]) :-
  Linha1 > Linha2,
  !.

ordena_posicoes((Linha1, Col1), (Linha2, Col2), [(Linha1, Col1), (Linha2, Col2)]) :-
  Linha1 =:= Linha2,
  Col1 < Col2,
  !.

ordena_posicoes((Linha1, Col1), (Linha2, Col2), [(Linha2, Col2), (Linha1, Col1)]) :-
  Linha1 =:= Linha2,
  Col1 > Col2,
  !.

%----------
%2.6 - cria_ponte/3
%----------
cria_ponte(Pos1, Pos2, ponte(PosMenor, PosMaior)) :-
  ordena_posicoes(Pos1, Pos2, [PosMenor, PosMaior]).


%----------
%2.7 - caminho_livre/5
%----------

%Duas ilhas deixam de ser vizinhas,
%apos a criacao de ponte(Pos1, Pos2), sse:
% - Essa ponte nao for entre as duas ilhas;
% - Pelo menos uma das posicoes entre as duas ilhas for ocupada pela ponte.

caminho_livre(Pos1, Pos2, _, ilha(_, Pos1), ilha(_, Pos2)) :- !.

caminho_livre(Pos1, Pos2, _, ilha(_, Pos2), ilha(_, Pos1)) :- !.

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
actualiza_vizinha_entrada(Pos1, Pos2, Posicoes, Ilha, Vizinhas, Vizinha) :-
  member(Vizinha, Vizinhas),
  caminho_livre(Pos1, Pos2, Posicoes, Ilha, Vizinha).

actualiza_vizinhas_entrada(Pos1, Pos2, Posicoes, [Ilha, Vizinhas, Pontes], [Ilha, NovasVizinhas, Pontes]) :-
  findall(Vizinha, actualiza_vizinha_entrada(Pos1, Pos2, Posicoes, Ilha, Vizinhas, Vizinha), NovasVizinhas).

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
%TODO: perguntar se este corte eh sempre vahlido 
% ou se preciso de ter um \+ member(...) dentro da 2a definicao
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
trata_ilhas_terminadas(Estado, Novo_estado) :-
  ilhas_terminadas(Estado, Ilhas_term),
  tira_ilhas_terminadas(Estado, Ilhas_term, Estado_intermedio),
  marca_ilhas_terminadas(Estado_intermedio, Ilhas_term, Novo_estado).

%----------
%2.16 - junta_pontes/5
%----------
%FIXME: this is horrible.
junta_pontes(Estado, Num_pontes, ilha(N_pontes_1, Pos1), ilha(N_pontes_2, Pos2), Novo_estado) :-
  %Retirar entradas antigas
  delete(Estado, [ilha(N_pontes_1, Pos1), VizinhasIlha1, PontesIlha1], Estado_intermedio_1),
  delete(Estado_intermedio_1, [ilha(N_pontes_2, Pos2), VizinhasIlha2, PontesIlha2], Estado_intermedio_2),

  cria_ponte(Pos1, Pos2, Ponte),
 
  length(Pontes, Num_pontes), maplist(=(Ponte), Pontes),

  %Adiciona as novas pontes
  append(Pontes, PontesIlha1, NovasPontesIlha1),
  append(Pontes, PontesIlha2, NovasPontesIlha2),
  
  Novo_N_pontes_1 is +(N_pontes_1, Num_pontes),
  Novo_N_pontes_2 is +(N_pontes_2, Num_pontes),

  %Adiciona as entradas atualizadas
  append(Estado_intermedio_2, [ilha(Novo_N_pontes_1, Pos1), VizinhasIlha1, NovasPontesIlha1], Estado_intermedio_3),
  append(Estado_intermedio_3, [ilha(Novo_N_pontes_2, Pos2), VizinhasIlha2, NovasPontesIlha2], Estado_intermedio_4),

  %Step 3
  actualiza_vizinhas_apos_pontes(Estado_intermedio_4, Pos1, Pos2, Estado_intermedio_5),
  trata_ilhas_terminadas(Estado_intermedio_5, Novo_estado).
