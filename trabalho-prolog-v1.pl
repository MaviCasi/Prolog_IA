/*********************************************
 * 1. DECLARAÇÃO DE PREDICADOS DINÂMICOS
 *********************************************/
:- dynamic(bateria/1).
:- dynamic(temperatura_motor/1).
:- dynamic(falha_ignicao/0).
:- dynamic(luz_bateria/0).
:- dynamic(barulho_incomum/0).
:- dynamic(luz_check_engine/0).
:- dynamic(luz_bateria/0).
:- dynamic(nivel_oleo/1).
:- dynamic(sensor_oxigenio/1).
:- dynamic(rotacao_alta/0).

/*********************************************
 * 2. FATOS BÁSICOS (SINTOMAS E CAUSAS)
 *    - Aqui definimos sintomas e as possíveis
 *      causas associadas a cada um deles. (não mexer)
 *********************************************/

/* Exemplos de causas representadas por termos que
   indicam possíveis problemas */
% falha_ignicao pode ser causada por:
causa_possivel(falha_ignicao, bateria_fraca).
causa_possivel(falha_ignicao, vela_ignicao_defeituosa).
causa_possivel(falha_ignicao, sensor_virabrequim_defeituoso).

% luz_check_engine pode ser causada por:
causa_possivel(luz_check_engine, sensor_oxigenio_defeituoso).
causa_possivel(luz_check_engine, problema_injecao).
causa_possivel(luz_check_engine, sistema_arrefecimento).

% luz_bateria pode ser causada por:
causa_possivel(luz_bateria, alternador_defeituoso).
causa_possivel(luz_bateria, correia_acessorios_rompida).
causa_possivel(luz_bateria, bateria_fraca).

% barulho_incomum pode ser causado por:
causa_possivel(barulho_incomum, problema_interno_motor).
causa_possivel(barulho_incomum, problema_transmissao).



/*********************************************
 * 3. REGRAS DE DIAGNÓSTICO PRINCIPAIS
 *    - Se determinados sintomas e leituras
 *      de sensores estiverem presentes,
 *      inferimos a causa provável.
 *********************************************/

% 3.1 Diagnóstico de bateria fraca
%    - Se há falha de ignição, luz de bateria acesa
%      e tensão da bateria < 12, conclui-se bateria_fraca.
diagnostico(bateria_fraca) :-
    falha_ignicao,
    luz_bateria,
    bateria(Voltage),
    Voltage < 12.

% 3.2 Diagnóstico de alternador defeituoso
%    - Se a bateria está fraca mesmo após recarga,
%      ou se a luz de bateria acende durante o uso,
%      suspeita do alternador.
diagnostico(alternador_defeituoso) :-
    luz_bateria,
    \+ diagnostico(bateria_fraca).  
    /* Se não foi diagnosticada bateria_fraca,
       mas a luz continua acesa, pode ser alternador. */

% 3.3 Diagnóstico de superaquecimento / sistema de arrefecimento
%    - Se temperatura do motor > 100°C e/ou check engine aceso,
%      indicamos problema de arrefecimento.
diagnostico(sistema_arrefecimento) :-
( temperatura_motor(T), T > 100 ; luz_check_engine ).

/ % 3.4 Diagnóstico de baixo nível de óleo
%    - Se nível do óleo está abaixo do mínimo,
%      sugerimos problema relacionado ao óleo./

diagnostico(baixo_nivel_oleo) :-
    nivel_oleo(N), N < 1.5.
diagnostico(baixo_nivel_oleo) :-
    nivel_oleo(N), N < 2.

% 3.5 Diagnóstico de vela de ignição defeituosa
%    - Se há falha de ignição frequente, mas a bateria está boa,
%      suspeitamos da vela de ignição.
diagnostico(vela_ignicao_defeituosa) :-
    falha_ignicao,
    bateria(V), V >= 12.

% 3.6 Diagnóstico de sensor de oxigênio defeituoso
%    - Se o sensor de oxigênio marca valor fora da faixa normal
%      e a luz de check engine pisca somente em alta rotação,
%      pode ser o sensor de oxigênio.
diagnostico(sensor_oxigenio_defeituoso) :-
    luz_check_engine,
    rotacao_alta,
    sensor_oxigenio(V), (V < 0.8 ; V > 1.2).

% 3.7 Diagnóstico de problema na injeção
%    - Se há falha em alta rotação e a leitura do sensor de
%      oxigênio está na faixa normal, pode ser a injeção.
diagnostico(problema_injecao) :-
    luz_check_engine,
    rotacao_alta,
    sensor_oxigenio(V), V >= 0.8, V =< 1.2.

% 3.8 Diagnóstico de problema na transmissão
%    - Se há barulho incomum e temperatura normal, mas não é problema interno do motor,
%      pode ser transmissão.
diagnostico(problema_transmissao) :-
    barulho_incomum,
    \+ luz_check_engine,
    temperatura_motor(T), T < 100.


/*********************************************
 * 4. RECOMENDAÇÕES DE AÇÃO
 *    - Associa cada causa a uma recomendação
 *      de manutenção / correção.
 *********************************************/
recomendacao(bateria_fraca, 'Recarregar ou substituir a bateria').
recomendacao(alternador_defeituoso, 'Verificar correia do alternador ou trocar alternador').
recomendacao(sistema_arrefecimento, 'Checar radiador, bomba d\'água, ventoinha e fluido de arrefecimento').
recomendacao(baixo_nivel_oleo, 'Completar ou trocar o óleo do motor').
recomendacao(vela_ignicao_defeituosa, 'Verificar e substituir as velas de ignicao').
recomendacao(sensor_oxigenio_defeituoso, 'Verificar ou substituir o sensor de oxigenio').
recomendacao(problema_injecao, 'Verificar sistema de injeção eletrônica').
recomendacao(problema_interno_motor, 'Levar o veículo para avaliação mecânica detalhada').
recomendacao(problema_transmissao, 'Verificar sistema de transmissão e câmbio').

/*********************************************
 * 5. PREDICADO PRINCIPAL DE DIAGNÓSTICO
 *    - Identifica todas as causas possíveis,
 *      exibe as recomendações. (não mexer)
 *********************************************/
diagnosticar :-
    % Encontra todas as causas que satisfazem as regras
    findall(Causa, diagnostico(Causa), ListaCausas),
    (   ListaCausas \= []
    ->  format('Possiveis problemas diagnosticados: ~w~n',[ListaCausas]),
        listar_recomendacoes(ListaCausas)
    ;   write('Nenhum problema foi diagnosticado com as informacoes atuais.'), nl
    ).

listar_recomendacoes([]).
listar_recomendacoes([Causa|Resto]) :-
    recomendacao(Causa, Rec),
    format(' -> Para ~w, recomenda-se: ~w~n', [Causa, Rec]),
    listar_recomendacoes(Resto).


/*********************************************
 * 6. EXEMPLOS DE CASOS DE TESTE
 *    - Cada cenário insere (assert) valores
 *      de sintomas e sensores, chama
 *      diagnosticar/0 e depois limpa o estado.
 * * (não mexer)
 *********************************************/
% Observação: Estes predicados são apenas exemplos
% de como testar. Ajuste conforme desejar.

caso_teste_1_partida_inconsistente :-
    write('=== Caso de Teste 1: Partida Inconsistente ==='), nl,
    limpar_estado,
    assertz(falha_ignicao),
    assertz(luz_bateria),
    assertz(bateria(11.8)),
    diagnosticar,
    limpar_estado.

caso_teste_2_superaquecimento :-
    write('=== Caso de Teste 2: Superaquecimento no Motor ==='), nl,
    limpar_estado,
    assertz(temperatura_motor(105)),
    assertz(nivel_oleo(1.5)),
    assertz(luz_check_engine),
    diagnosticar,
    limpar_estado.

caso_teste_3_motor_engasgado_altas_rotacoes :-
    write('=== Caso de Teste 3: Motor Engasgado em Altas Rotacoes ==='), nl,
    limpar_estado,
    assertz(rotacao_alta),
    assertz(luz_check_engine),
    assertz(sensor_oxigenio(1.0)), % valor fora do normal
    diagnosticar,
    limpar_estado.

caso_teste_4_ruidos_ao_acelerar :-
    write('=== Caso de Teste 4: Ruidos no Motor ao Acelerar ==='), nl,
    limpar_estado,
    assertz(barulho_incomum),
    assertz(temperatura_motor(90)),  % dentro da faixa normal
    diagnosticar,
    limpar_estado.

% Predicado para limpar o estado dinâmico antes/depois dos testes
limpar_estado :-
    retractall(bateria(_)),
    retractall(temperatura_motor(_)),
    retractall(nivel_oleo(_)),
    retractall(sensor_oxigenio(_)),
    retractall(luz_check_engine),
    retractall(luz_bateria),
    retractall(falha_ignicao),
    retractall(barulho_incomum),
    retractall(rotacao_alta).
    
 :- initialization(main) 

main :-
    write('=== Executando varios casos de teste ==='), nl,
    caso_teste_1_partida_inconsistente,
    caso_teste_2_superaquecimento,
    halt.
