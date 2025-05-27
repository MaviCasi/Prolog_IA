/*********************************************
 * 1. DECLARAÇÃO DE PREDICADOS DINÂMICOS
 *********************************************/
:- dynamic(bateria/1).                % Permite adicionar/remover leituras da bateria dinamicamente
:- dynamic(temperatura_motor/1).      % Permite adicionar/remover leituras da temperatura do motor
:- dynamic(nivel_oleo/1).             % Permite adicionar/remover leituras do nível de óleo
:- dynamic(sensor_oxigenio/1).        % Permite adicionar/remover leituras do sensor de oxigênio
:- dynamic(falha_ignicao/0).          % Permite indicar dinamicamente falha de ignição
:- dynamic(barulho_incomum/0).        % Permite indicar dinamicamente barulho incomum no motor
:- dynamic(rotacao_alta/0).           % Permite indicar dinamicamente rotação alta do motor
:- dynamic(luz_check_engine/0).       % Permite indicar dinamicamente luz de check engine acesa
:- dynamic(luz_bateria/0).            % Permite indicar dinamicamente luz de bateria acesa


/*********************************************
 * 2. FATOS BÁSICOS (SINTOMAS E CAUSAS)
 *********************************************/

/* Exemplos de causas representadas por termos que
   indicam possíveis problemas */
causa(bateria_fraca).                 % Possível causa: bateria fraca
causa(alternador_defeituoso).         % Possível causa: alternador defeituoso
causa(sistema_arrefecimento).         % Possível causa: problema no sistema de arrefecimento
causa(baixo_nivel_oleo).              % Possível causa: baixo nível de óleo
causa(vela_ignicao_defeituosa).       % Possível causa: vela de ignição defeituosa
causa(sensor_oxigenio_defeituoso).    % Possível causa: sensor de oxigênio defeituoso
causa(problema_injecao).              % Possível causa: problema na injeção eletrônica
causa(problema_transmissao).          % Possível causa: problema na transmissão
causa(problema_interno_motor).        % Possível causa: problema interno no motor (ex: biela, pistão)


/*********************************************
 * 3. REGRAS DE DIAGNÓSTICO PRINCIPAIS
 *********************************************/

% 3.1 Diagnóstico de bateria fraca (prioridade máxima com corte)
% Diagnóstico de bateria fraca (prioridade máxima com corte)
diagnostico(bateria_fraca) :-
    falha_ignicao,                    % Deve haver falha de ignição
    luz_bateria,                      % Luz da bateria deve estar acesa
    bateria(Voltage),                 % Lê o valor da bateria
    Voltage < 12, !.                  % Se tensão < 12V, diagnostica bateria fraca e não tenta alternador


% ...existing code...

% 3.2 Diagnóstico de alternador defeituoso (só se não for bateria)
% Diagnóstico de alternador defeituoso (só se não for bateria)
diagnostico(alternador_defeituoso) :-
    luz_bateria,                      % Luz da bateria acesa
    bateria(Voltage),                 % Lê o valor da bateria
    Voltage >= 12.                    % Se tensão >= 12V, pode ser alternador


% ...existing code...  

% 3.4 Diagnóstico de baixo nível de óleo
diagnostico(baixo_nivel_oleo) :-      % Diagnóstico de baixo nível de óleo
    nivel_oleo(N), N < 2.0.           % Se nível de óleo < 2.0, diagnostica baixo nível de óleo

% 3.5 Diagnóstico de vela de ignição defeituosa
diagnostico(vela_ignicao_defeituosa) :- % Diagnóstico de vela de ignição defeituosa
    falha_ignicao,                      % Deve haver falha de ignição
    bateria(V), V >= 12.2.              % Se bateria está boa, pode ser vela de ignição


% 3.6 Diagnóstico de sensor de oxigênio defeituoso
diagnostico(sensor_oxigenio_defeituoso) :-    % Diagnóstico de sensor de oxigênio defeituoso
    sensor_oxigenio(Val), (Val < 0.8 ; Val > 1.2), % Valor do sensor fora do normal
    luz_check_engine,                         % Luz de check engine acesa
    rotacao_alta.                             % Motor em alta rotação

% 3.7 Diagnóstico de problema na injeção
diagnostico(problema_injecao) :-                   % Diagnóstico de problema na injeção
    rotacao_alta,                                  % Motor em alta rotação
    luz_check_engine,                              % Luz de check engine acesa
    sensor_oxigenio(Val), Val >= 0.8, Val =< 1.2.  % Sensor de oxigênio dentro do normal

% 3.8 Diagnóstico de problema na transmissão
diagnostico(problema_transmissao) :-  % Diagnóstico de problema na transmissão
    barulho_incomum,                  % Barulho incomum no motor
    luz_check_engine,                 % Luz de check engine acesa
    temperatura_motor(T), T < 100.    % Temperatura do motor normal


/*********************************************
 * 4. RECOMENDAÇÕES DE AÇÃO
 *********************************************/
recomendacao(bateria_fraca, 'Verificar e recarregar ou substituir a bateria').
recomendacao(alternador_defeituoso, 'Verificar ou substituir a correia do alternador e o próprio alternador').
recomendacao(baixo_nivel_oleo, 'Completar ou trocar o óleo do motor').
recomendacao(vela_ignicao_defeituosa, 'Verificar e substituir as velas de ignição').
recomendacao(sensor_oxigenio_defeituoso, 'Verificar o sensor de oxigênio e chicote elétrico').
recomendacao(problema_injecao, 'Verificar sistema de injeção eletrônica e bicos injetores').
recomendacao(problema_transmissao, 'Levar o veículo para avaliação da transmissão').
recomendacao(problema_interno_motor, 'Avaliar internamente o motor por um mecânico especializado').

/*********************************************
 * 4.1 EXPLICAÇÕES DE DIAGNÓSTICO E DESCARTE
 *********************************************/


explicacao(baixo_nivel_oleo) :-  % Explicação do diagnóstico de baixo_nivel_oleo
    nivel_oleo(N), N < 2.0, !,   % Se o nível de óleo está abaixo de 2.0, explica com o valor real
    write('Diagnóstico: Baixo nível de óleo porque o sensor indicou '), write(N), write(', abaixo do mínimo.'), nl.
explicacao(baixo_nivel_oleo) :-  % Explicação do diagnóstico de baixo_nivel_oleo
    write('O diagnóstico de baixo_nivel_oleo só ocorre se o sensor indicar valor abaixo de 2.0.'), nl. % Caso não haja fato, explica a lógica


explicacao(alternador_defeituoso) :-     % Explicação do diagnóstico de alternador_defeituoso
    bateria(V), V >= 12, luz_bateria, !, % Se a bateria está normal e luz acesa, explica com o valor real
    write('Diagnóstico: Alternador defeituoso porque a luz da bateria está acesa, mas a tensão da bateria está normal ('), write(V), write('V).'), nl.
explicacao(alternador_defeituoso) :-     % Explicação do diagnóstico de alternador_defeituoso
    write('O diagnóstico de alternador_defeituoso só ocorre se a luz da bateria estiver acesa e a tensão igual ou acima de 12V.'), nl. % Caso não haja fato, explica a lógica


explicacao(bateria_fraca) :-                           % Explicação do diagnóstico de bateria_fraca
    bateria(V), V < 12, falha_ignicao, luz_bateria, !, % Se a bateria está baixa, há falha de ignição e luz acesa, explica com o valor real
    write('Diagnóstico: Bateria fraca porque a tensão lida foi '), write(V),
    write('V, abaixo do mínimo recomendado (12V), com falha de ignição e luz de bateria acesa.'), nl.
explicacao(bateria_fraca) :-                           % Explicação do diagnóstico de bateria_fraca
    write('O diagnóstico de bateria_fraca só ocorre se houver falha de ignição, luz da bateria acesa e tensão abaixo de 12V.'), nl. % Caso não haja fato, explica a lógica


explicacao(vela_ignicao_defeituosa) :-                 % Explicação do diagnóstico de vela_ignicao_defeituosa
    falha_ignicao, bateria(V), V >= 12.2, !,           % Se há falha de ignição e bateria normal, explica com o valor real
    write('Diagnóstico: Vela de ignição defeituosa porque há falha de ignição mesmo com bateria normal ('), write(V), write('V).'), nl.
explicacao(vela_ignicao_defeituosa) :-                 % Explicação do diagnóstico de vela_ignicao_defeituosa
    write('O diagnóstico de vela_ignicao_defeituosa só ocorre se houver falha de ignição e bateria igual ou acima de 12.2V.'), nl. % Caso não haja fato, explica a lógica


por_que_nao(baixo_nivel_oleo) :-        % Explicação do porquê NÃO foi dado o diagnóstico de baixo_nivel_oleo
    nivel_oleo(N), N >= 2.0, !,         % Se o nível de óleo está suficiente, explica com o valor real
    write('Baixo nível de óleo foi descartado porque o sensor indicou '), write(N), write(', valor considerado suficiente.'), nl.
por_que_nao(baixo_nivel_oleo) :-        % Explicação do porquê NÃO foi dado o diagnóstico de baixo_nivel_oleo
    write('Baixo nível de óleo seria descartado se o sensor indicasse valor igual ou acima de 2.0.'), nl. % Caso não haja fato, explica a lógica


por_que_nao(alternador_defeituoso) :-         % Explicação do porquê NÃO foi dado o diagnóstico de alternador_defeituoso
    (bateria(V), V < 12 ; \+ luz_bateria), !, % Se a bateria está baixa ou luz não acesa, explica com o valor real
    write('Alternador defeituoso foi descartado porque a tensão da bateria está baixa ou a luz da bateria não está acesa.'), nl.
por_que_nao(alternador_defeituoso) :-         % Explicação do porquê NÃO foi dado o diagnóstico de alternador_defeituoso
    write('Alternador defeituoso seria descartado se a luz da bateria não estivesse acesa ou a tensão estivesse baixa.'), nl. % Caso não haja fato, explica a lógica

x
por_que_nao(bateria_fraca) :-    % Explicação do porquê NÃO foi dado o diagnóstico de alternador_defeituoso
    bateria(V), V >= 12, !,      % Se a bateria está normal, explica com o valor real
    write('Bateria fraca foi descartada porque a tensão da bateria está em '), write(V), write('V, valor considerado normal.'), nl.
por_que_nao(bateria_fraca) :-    % Explicação do porquê NÃO foi dado o diagnóstico de alternador_defeituoso
    write('Bateria fraca seria descartada se a tensão da bateria estivesse igual ou acima de 12V.'), nl. % Caso não haja fato, explica a lógica


por_que_nao(vela_ignicao_defeituosa) :-           % Explicação do porquê NÃO foi dado o diagnóstico de vela_ignicao_defeituosa
    (bateria(V), V < 12.2 ; \+ falha_ignicao), !, % Se a bateria está baixa ou não há falha de ignição, explica com o valor real
    write('Vela de ignição defeituosa foi descartada porque não há falha de ignição ou a bateria está abaixo de 12.2V.'), nl.
por_que_nao(vela_ignicao_defeituosa) :-           % Explicação do porquê NÃO foi dado o diagnóstico de vela_ignicao_defeituosa
    write('Vela de ignição defeituosa seria descartada se não houvesse falha de ignição ou a bateria estivesse abaixo de 12.2V.'), nl. % Caso não haja fato, explica a lógica

justificativa(bateria_fraca) :-
    write('Para diagnosticar bateria_fraca, o sistema verifica:'), nl, % Início da explicação lógica do diagnóstico
    write('- Se há falha de ignição.'), nl,                            % Critério 1
    write('- Se a luz da bateria está acesa.'), nl,                    % Critério 2
    write('- Se a tensão da bateria está abaixo de 12V.'), nl,         % Critério 3
    write('Se todas essas condições forem verdadeiras ao mesmo tempo, o diagnóstico é bateria_fraca.'), nl. % Conclusão

justificativa(alternador_defeituoso) :-
    write('Para diagnosticar alternador_defeituoso, o sistema verifica:'), nl, % Início da explicação lógica do diagnóstico
    write('- Se a luz da bateria está acesa.'), nl,                            % Critério 1
    write('- Se a tensão da bateria está igual ou acima de 12V.'), nl,         % Critério 2
    write('Se essas condições forem verdadeiras, o diagnóstico é alternador_defeituoso.'), nl. % Conclusão

justificativa(baixo_nivel_oleo) :-
    write('Para diagnosticar baixo_nivel_oleo, o sistema verifica:'), nl, % Início da explicação lógica do diagnóstico
    write('- Se o nível de óleo está abaixo de 2.0.'), nl,                % Critério
    write('Se essa condição for verdadeira, o diagnóstico é baixo_nivel_oleo.'), nl. % Conclusão
justificativa(bateria_fraca) :-
    write('Para diagnosticar bateria_fraca, o sistema verifica:'), nl,
    write('- Se há falha de ignição.'), nl,
    write('- Se a luz da bateria está acesa.'), nl,
    write('- Se a tensão da bateria está abaixo de 12V.'), nl,
    write('Se todas essas condições forem verdadeiras ao mesmo tempo, o diagnóstico é bateria_fraca.'), nl.

justificativa(alternador_defeituoso) :-
    write('Para diagnosticar alternador_defeituoso, o sistema verifica:'), nl,
    write('- Se a luz da bateria está acesa.'), nl,
    write('- Se a tensão da bateria está igual ou acima de 12V.'), nl,
    write('Se essas condições forem verdadeiras, o diagnóstico é alternador_defeituoso.'), nl.

justificativa(baixo_nivel_oleo) :-
    write('Para diagnosticar baixo_nivel_oleo, o sistema verifica:'), nl,
    write('- Se o nível de óleo está abaixo de 2.0.'), nl,
    write('Se essa condição for verdadeira, o diagnóstico é baixo_nivel_oleo.'), nl.

/*********************************************
 * 5. PREDICADO PRINCIPAL DE DIAGNÓSTICO
 *********************************************/
diagnosticar :-
    findall(Causa, diagnostico(Causa), ListaCausas), % Busca todas as causas possíveis
    (   ListaCausas \= []
    ->  format('Possiveis problemas diagnosticados: ~w~n',[ListaCausas]), % Exibe causas
        listar_recomendacoes(ListaCausas) % Exibe recomendações para cada causa
    ;   write('Nenhum problema foi diagnosticado com as informacoes atuais.'), nl
    ).

listar_recomendacoes([]). % Caso base: lista vazia, não faz nada
listar_recomendacoes([Causa|Resto]) :-
    recomendacao(Causa, Rec), % Busca recomendação para a causa
    format(' -> Para ~w, recomenda-se: ~w~n', [Causa, Rec]), % Exibe recomendação
    listar_recomendacoes(Resto). % Repete para o resto da lista


/*********************************************
 * 6. EXEMPLOS DE CASOS DE TESTE
 *********************************************/
caso_teste_1_partida_inconsistente :-
    write('=== Caso de Teste 1: Partida Inconsistente ==='), nl,
    limpar_estado,                         % Limpa fatos antigos
    assertz(falha_ignicao),                % Adiciona falha de ignição
    assertz(luz_bateria),                  % Adiciona luz de bateria acesa
    assertz(bateria(11.8)),                % Adiciona leitura de bateria baixa
    diagnosticar.                          % Executa diagnóstico
   

caso_teste_2_superaquecimento :-
    write('=== Caso de Teste 2: Superaquecimento no Motor ==='), nl,
    limpar_estado,
    assertz(temperatura_motor(105)),       % Temperatura alta
    assertz(nivel_oleo(1.5)),              % Nível de óleo baixo
    assertz(luz_check_engine),             % Luz de check engine acesa
    diagnosticar.
    

caso_teste_3_motor_engasgado_altas_rotacoes :-
    write('=== Caso de Teste 3: Motor Engasgado em Altas Rotacoes ==='), nl,
    limpar_estado,
    assertz(rotacao_alta),                 % Motor em alta rotação
    assertz(luz_check_engine),             % Luz de check engine acesa
    assertz(sensor_oxigenio(1.0)),         % Valor do sensor de oxigênio fora do normal
    diagnosticar.
    

caso_teste_4_ruidos_ao_acelerar :-
    write('=== Caso de Teste 4: Ruidos no Motor ao Acelerar ==='), nl,
    limpar_estado,
    assertz(barulho_incomum),              % Barulho incomum
    assertz(temperatura_motor(90)),        % Temperatura normal
    diagnosticar.
    

% Cenário de conflito: bateria fraca vs alternador defeituoso
caso_teste_5_conflito_bateria_alternador :-
    write('=== Caso de Teste 5: Conflito Bateria Fraca vs Alternador ==='), nl, % Exibe o nome do caso de teste no terminal
    limpar_estado,                         % Limpa todos os fatos dinâmicos anteriores para garantir que o teste comece limpo
    assertz(falha_ignicao),                % Adiciona o fato de que há falha de ignição
    assertz(luz_bateria),                  % Adiciona o fato de que a luz da bateria está acesa
    assertz(bateria(11.5)),                % Adiciona o fato de que a bateria está com tensão baixa (11.5V)
    diagnosticar.                          % Executa o diagnóstico com os fatos atuais
    

caso_teste_6_conflito_so_alternador :-
    write('=== Caso de Teste 6: Conflito só Alternador ==='), nl, % Exibe o nome do caso de teste
    limpar_estado,                         % Limpa todos os fatos dinâmicos anteriores para garantir teste limpo
    assertz(luz_bateria),                  % Adiciona o fato de que a luz da bateria está acesa
    assertz(bateria(12.5)),                % Adiciona o fato de que a bateria está com tensão normal (12.5V)
    diagnosticar.                          % Executa o diagnóstico com os fatos atuais
    

% Predicado para limpar o estado dinâmico antes/depois dos testes
limpar_estado :-
    retractall(bateria(_)),                % Remove todas as leituras de bateria
    retractall(temperatura_motor(_)),      % Remove todas as leituras de temperatura
    retractall(nivel_oleo(_)),             % Remove todas as leituras de óleo
    retractall(sensor_oxigenio(_)),        % Remove todas as leituras do sensor de oxigênio
    retractall(luz_check_engine),          % Remove luz de check engine
    retractall(luz_bateria),               % Remove luz de bateria
    retractall(falha_ignicao),             % Remove falha de ignição
    retractall(barulho_incomum),           % Remove barulho incomum
    retractall(rotacao_alta).              % Remove rotação alta

    
% Inicialização automática: executa os principais casos de teste ao carregar o arquivo
:- initialization(main).

main :-
    write('=== Executando varios casos de teste ==='), nl,
    caso_teste_1_partida_inconsistente,
    caso_teste_2_superaquecimento,
    caso_teste_5_conflito_bateria_alternador,
    caso_teste_6_conflito_so_alternador.
   
