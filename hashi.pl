% Rafael Girao, ist199309

:- [codigo_comum].

%----------
% 2.1 - extrai_ilhas_linha(N_L, Linha, Ilha)
% Ilhas eh a lista ordenada cujos elementos sao as ilhas da linha Ilha
% Linha eh a N_Lesima linha de um Puzzle
%----------

%Caso particular
extrai_ilha_linha(N_L, Linha, ilha(N_Pontes, (N_L, N_Col))) :-
  nth1(N_Col, Linha, N_Pontes),
  N_Pontes =\= 0.

%Caso geral
extrai_ilhas_linha(N_L, Linha, Ilhas) :-
  findall(Ilha, extrai_ilha_linha(N_L, Linha, Ilha), Ilhas).

%----------
% 2.2 - ilhas(Puz, Ilhas)
% Ilhas eh a lista ordenada de Ilhas 
% cujos elementos sao as ilhas do Puzzle Puz
%----------

ilhas_linha(Puz, IlhasLinha) :-
  nth1(N_Linha, Puz, Linha_Puzzle),
  extrai_ilhas_linha(N_Linha, Linha_Puzzle, IlhasLinha).
%
ilhas(Puz, Ilhas) :-
  findall(IlhasLinha, ilhas_linha(Puz, IlhasLinha), ListaAninhadaIlhas),
  flatten(ListaAninhadaIlhas, Ilhas).

%----------
% 2.3 - vizinhas(Ilhas, Ilha, Vizinhas)
% Vizinhas eh a lista ordenada de ilhas extraidas de Ilhas
% que sao vizinhas de Ilha
%----------

%TODO: perguntar se posso usar um predicado feito muito mais ah frente
%para definir este

%Averigua se ha alguma ilha entre a ilha em Pos1 e a ilha em Pos2
ha_ilha_no_meio(ilha(_, Pos1), ilha(_, Pos2), ilha(_, Pos3)) :-
  posicoes_entre(Pos1, Pos2, Posicoes),
  member(Pos3, Posicoes).
  
%Certifica que nao ha ilhas entre Ilha1 e Ilha2
nao_ha_ilhas_no_meio(Ilhas, Ilha1, Ilha2) :-
  forall(member(Ilha3, Ilhas), \+ha_ilha_no_meio(Ilha1, Ilha2, Ilha3)).
  
%sao_vizinhas(Ilha1, Ilha2) averigua se Ilha1 e Ilha2 poderao ser vizinhas
%Uma ilha nao pode ser vizinha dela propria
sao_vizinhas(Ilha, Ilha) :-
  !,
  fail.

sao_vizinhas(ilha(_, (N_Linha_1, _)), ilha(_, (N_Linha_2, _))) :-
  N_Linha_1 =:= N_Linha_2.

sao_vizinhas(ilha(_, (_, N_Col_1)), ilha(_, (_, N_Col_2))) :-
  N_Col_1 =:= N_Col_2.

vizinha(Ilhas, Ilha, IlhaVz) :-
  member(IlhaVz, Ilhas),
  sao_vizinhas(Ilha, IlhaVz),
  nao_ha_ilhas_no_meio(Ilhas, Ilha, IlhaVz).

vizinhas(Ilhas, Ilha, Vizinhas) :-
  findall(IlhaVizinha, vizinha(Ilhas, Ilha, IlhaVizinha), Vizinhas).
%----------
% 2.4 - estado(Ilhas, Estado)
% Estado eh a ista ordenada cujos elementos sao as entradas referentes
% a cada uma das ilhas
%----------
%Caso particular de uma unica entrada
estado_singular(Ilhas, [Ilha, Vizinhas, []]) :-
  member(Ilha, Ilhas),
  vizinhas(Ilhas, Ilha, Vizinhas).

%Caso geral de todas as entradas 
estado(Ilhas, Estado) :-
  findall(EstadoIlha, estado_singular(Ilhas, EstadoIlha), Estado).

%----------
%2.5 - posicoes_entre/3

% posicoes_entre(Pos1, Pos2, Posicoes)
% Posicoes eh a lista ordenada de Posicoes entre Pos1 e Pos2
%----------
%Caso de Pos1 e Pos2 pertenceram ah mesma linha
posicao_entre((Linha1, Col1), (Linha2, Col2), (Linha1, Coluna)) :-
  Linha1 =:= Linha2,
  !,
  Min is min(Col1, Col2),
  Max is max(Col1, Col2),

  SegundaCol is +(Min, 1),
  PenultimaCol is -(Max, 1),

  between(SegundaCol, PenultimaCol, Coluna).
%Caso de pertenceram ah mesma coluna
posicao_entre((Linha1, Col1), (Linha2, Col2), (Linha, Col1)) :-
  Col1 =:= Col2,
  !,
  Min is min(Linha1, Linha2),
  Max is max(Linha1, Linha2),

  SegundaLinha is +(Min, 1),
  PenultimaLinha is -(Max, 1),

  between(SegundaLinha, PenultimaLinha, Linha).

%Caso nao pertencam nem ah mesma linha nem coluna, nao ha posicoes entre elas
posicao_entre((_, _), (_, _), _) :-
  !,
  fail.
%Caso geral
posicoes_entre(Pos1, Pos2, Posicoes) :-
  bagof(Posicao, posicao_entre(Pos1, Pos2, Posicao), Posicoes).

%----------
% ordena_posicoes (Pos1, Pos2, [PosMenor, PosMaior])
% Sendo Pos1 e Pos2 duas Posicoes
% [PosMenor, PosMaior] eh a lista que contem as duas posicoes por ordem crescente
%----------
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
% 2.6 - cria_ponte(Pos1, Pos2, Ponte)
% Ponte eh a estrutura ponte(PosMenor, PosMaior)
% Em que PosMenor e PosMaior sao Pos1 e Pos2 por ordem crescente
%----------
cria_ponte(Pos1, Pos2, ponte(PosMenor, PosMaior)) :-
  ordena_posicoes(Pos1, Pos2, [PosMenor, PosMaior]).

%----------
% 2.7 - caminho_livre(Pos1, Pos2, Posicoes, I, Vz)
% Averigua se a criacao de uma ponte entre Pos1 e Pos2 nao faz com que 
% as ilhas I e Vz deixem de ser vizinhas
% Posicoes eh a lista ordenada de posicoes entre Pos1 e Pos2
%----------

%Casos em que a ponte seria entre as duas ilhas, nao deixam de ser vizinhas
caminho_livre(Pos1, Pos2, _, ilha(_, Pos1), ilha(_, Pos2)) :- !.
caminho_livre(Pos1, Pos2, _, ilha(_, Pos2), ilha(_, Pos1)) :- !.

caminho_livre(Pos1, Pos2, _, ilha(_, Pos_I), ilha(_, Pos_Vz)) :-
  ordena_posicoes(Pos1, Pos2, [MenorPos1, MaiorPos1]),
  ordena_posicoes(Pos_I, Pos_Vz, [MenorPos2, MaiorPos2]),
  MenorPos1 = MenorPos2,
  MaiorPos1 = MaiorPos2,
  !.

caminho_livre(_, _, PosicoesPonte, ilha(_, Pos_I), ilha(_, Pos_Vz)) :-
  member(Posicao, PosicoesPonte),
  posicoes_entre(Pos_I, Pos_Vz, PosicoesIlhaVz),
  member(Posicao, PosicoesIlhaVz),
  !,
  fail.

caminho_livre(_,_, _, _, _) :- !.

%----------
%2.8 - actualiza_vizinhas_entrada/5
%----------
actualiza_vizinha_entrada(Pos1, Pos2, Posicoes, Ilha, Vizinhas, Vizinha) :-
  member(Vizinha, Vizinhas),
  caminho_livre(Pos1, Pos2, Posicoes, Ilha, Vizinha).

actualiza_vizinhas_entrada(Pos1, Pos2, Posicoes, [Ilha, Vizinhas, Pontes], [Ilha, NovasVizinhas, Pontes]) :-
  findall(
    Vizinha,
    actualiza_vizinha_entrada(Pos1, Pos2, Posicoes, Ilha, Vizinhas, Vizinha),
    NovasVizinhas).

%----------
%2.9 - actualiza_vizinhas_apos_pontes/4
%----------
actualiza_vizinha_apos_pontes(Estado, Pos1, Pos2, Posicoes, EntradaNova) :-
  member(Entrada, Estado),
  actualiza_vizinhas_entrada(Pos1, Pos2, Posicoes, Entrada, EntradaNova).

actualiza_vizinhas_apos_pontes(Estado, Pos1, Pos2, NovoEstado) :-
  posicoes_entre(Pos1, Pos2, Posicoes),
  findall(
    EntradaNova,
    actualiza_vizinha_apos_pontes(Estado, Pos1, Pos2, Posicoes, EntradaNova),
    NovoEstado).

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
tira_ilha_terminada_entrada_aux(Ilhas_term, Vizinhas, IlhaVizinha) :-
  member(IlhaVizinha, Vizinhas),
  \+ member(IlhaVizinha, Ilhas_term).

tira_ilhas_terminadas_entrada(Ilhas_term, [Ilha, Vizinhas, Pontes], [Ilha, NovaVizinhas, Pontes]) :-
  findall(IlhaVizinha,
  tira_ilha_terminada_entrada_aux(Ilhas_term, Vizinhas, IlhaVizinha),
  NovaVizinhas).

%----------
%2.12 - tira_ilhas_terminadas/3
%----------
tira_ilhas_terminadas_aux(Estado, Ilhas_term, Nova_entrada) :-
  member(Entrada, Estado),
  tira_ilhas_terminadas_entrada(Ilhas_term, Entrada, Nova_entrada).


tira_ilhas_terminadas(Estado, Ilhas_term, Novo_estado) :-
  findall(Nova_entrada, tira_ilhas_terminadas_aux(Estado, Ilhas_term, Nova_entrada), Novo_estado).
%----------
%2.13 - tira_ilhas_terminadas_entrada/3
%----------

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

junta_pontes(Estado, Num_pontes, ilha(N_pontes_1, Pos1), ilha(N_pontes_2, Pos2), Novo_estado) :-
  nth0(Indice_1, Estado, [ilha(N_pontes_1, Pos1), VizinhasIlha1, PontesIlha1], Estado_intermedio_1),
  nth0(Indice_2, Estado_intermedio_1, [ilha(N_pontes_2, Pos2), VizinhasIlha2, PontesIlha2], Estado_intermedio_2),

  cria_ponte(Pos1, Pos2, Ponte),
  %Cria a lista de pontes necessaria
  length(Pontes, Num_pontes), maplist(=(Ponte), Pontes),

  %Adiciona as novas pontes
  append(Pontes, PontesIlha1, NovasPontesIlha1),
  append(Pontes, PontesIlha2, NovasPontesIlha2),

  %Reinsere as entradas atualizadas
  nth0(Indice_2, Estado_intermedio_3, [ilha(N_pontes_2, Pos2), VizinhasIlha2, NovasPontesIlha2],
    Estado_intermedio_2),
  nth0(Indice_1, Estado_intermedio_4, [ilha(N_pontes_1, Pos1), VizinhasIlha1, NovasPontesIlha1],
    Estado_intermedio_3),

  %Step 3
  actualiza_vizinhas_apos_pontes(Estado_intermedio_4, Pos1, Pos2, Estado_intermedio_5),
  trata_ilhas_terminadas(Estado_intermedio_5, Novo_estado).
