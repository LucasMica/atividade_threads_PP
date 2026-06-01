-module(worker).

-export([buscar_maior/2]).

-record(funcionario, {
    codigo,
    nome,
    salario,
    cidade
}).

buscar_maior(Pai, Linhas) ->

    Maior = encontrar_maior(Linhas, undefined),

    Pai ! {resultado, Maior}.

encontrar_maior([], Maior) ->
    Maior;

encontrar_maior([Linha | Resto], undefined) ->

    Funcionario = converter(Linha),

    encontrar_maior(Resto, Funcionario);

encontrar_maior([Linha | Resto], MaiorAtual) ->

    Funcionario = converter(Linha),

    NovoMaior =
        case Funcionario#funcionario.salario >
             MaiorAtual#funcionario.salario of

            true ->
                Funcionario;

            false ->
                MaiorAtual
        end,

    encontrar_maior(Resto, NovoMaior).

converter(Linha) ->

    LinhaLimpa = string:trim(Linha),

    [CodigoStr, Nome, SalarioStr, Cidade] =
        string:split(LinhaLimpa, ",", all),

    #funcionario{
        codigo = list_to_integer(CodigoStr),
        nome = Nome,
        salario = list_to_float(SalarioStr),
        cidade = Cidade
    }.