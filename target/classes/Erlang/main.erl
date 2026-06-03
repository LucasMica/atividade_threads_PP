-module(main).

-export([start/2]).

-record(funcionario, {
    codigo,
    nome,
    salario,
    cidade
}).

start(Arquivo, NumProcessos) ->

    Inicio = erlang:monotonic_time(millisecond),

    {ok, Binario} = file:read_file(Arquivo),

    Texto = binary_to_list(Binario),

    Linhas =
        [L || L <- string:split(Texto, "\n", all),
              string:trim(L) /= ""],

    Blocos = dividir(Linhas, NumProcessos),

    Pai = self(),

    lists:foreach(
        fun(Bloco) ->
            spawn(
                worker,
                buscar_maior,
                [Pai, Bloco]
            )
        end,
        Blocos
    ),

    Resultados = coletar(length(Blocos), []),

    MaiorGlobal = vencedor(Resultados),

    Fim = erlang:monotonic_time(millisecond),

    Tempo = Fim - Inicio,

    io:format("~n====================================~n"),
    io:format("RESULTADO FINAL~n"),
    io:format("====================================~n"),
    io:format("Codigo: ~p~n",
              [MaiorGlobal#funcionario.codigo]),
    io:format("Nome: ~s~n",
              [MaiorGlobal#funcionario.nome]),
    io:format("Cidade: ~s~n",
              [MaiorGlobal#funcionario.cidade]),
    io:format("Maior salario: R$ ~.2f~n",
              [MaiorGlobal#funcionario.salario]),
    io:format("Processos utilizados: ~p~n",
              [NumProcessos]),
    io:format("Tempo de execucao: ~p ms~n",
              [Tempo]),
    io:format("====================================~n~n"),

    MaiorGlobal.

%% =====================================================
%% Divide as linhas em N blocos
%% =====================================================

dividir(Linhas, NumProcessos) ->

    TotalLinhas = length(Linhas),

    TamanhoBloco =
        case TotalLinhas div NumProcessos of
            0 -> 1;
            Valor -> Valor
        end,

    dividir_aux(Linhas, TamanhoBloco, []).

dividir_aux([], _, Acumulado) ->
    lists:reverse(Acumulado);

dividir_aux(Linhas, TamanhoBloco, Acumulado) ->

    if
        length(Linhas) > TamanhoBloco ->

            {Bloco, Resto} =
                lists:split(
                    TamanhoBloco,
                    Linhas
                ),

            dividir_aux(
                Resto,
                TamanhoBloco,
                [Bloco | Acumulado]
            );

        true ->

            lists:reverse(
                [Linhas | Acumulado]
            )
    end.

%% =====================================================
%% Recebe respostas dos workers
%% =====================================================

coletar(0, Resultados) ->
    Resultados;

coletar(N, Resultados) ->

    receive

        {resultado, Funcionario} ->

            coletar(
                N - 1,
                [Funcionario | Resultados]
            )

    end.

%% =====================================================
%% Encontra o maior entre os retornados
%% =====================================================

vencedor([Primeiro | Resto]) ->

    lists:foldl(

        fun(Funcionario, MaiorAtual) ->

            case Funcionario#funcionario.salario >
                 MaiorAtual#funcionario.salario of

                true ->
                    Funcionario;

                false ->
                    MaiorAtual
            end

        end,

        Primeiro,

        Resto
    ).