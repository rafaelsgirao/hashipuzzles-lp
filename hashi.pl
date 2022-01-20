% Rafael Girao, ist199309

:- [codigo_comum].

%----------
%2.1 - Predicado extrai_ilhas_linhas
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
%Codigo Auxiliar
%----------

%Construtor da estrutura Ilha
faz_ilha(N, N_Linha, N_Col, ilha(N, (N_Linha, N_Col))).