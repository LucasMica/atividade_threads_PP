-module(main).
-export([start/2]).

-record(funcionario, {codigo, nome, salario, cidade}).

start(Arquivo, NumProcessos) ->
  Inicio = erlang:monotonic_time(millisecond),

  {ok, Binario} = file:read_file(Arquivo),

  %% Ele corta o arquivo bruto de 100MB em 4 pedaços de 25MB quase instantaneamente.
  Blocos = fatiar_binario(Binario, NumProcessos),

  Pai = self(),

  lists:foreach(
    fun(Bloco) -> spawn(worker, buscar_maior, [Pai, Bloco]) end,
    Blocos
  ),

  Resultados = coletar(length(Blocos), []),

  {MaiorSalarioGlobal, LinhaCampeaa} = vencedor(Resultados),
  MaiorGlobal = converter_linha_final(LinhaCampeaa, MaiorSalarioGlobal),

  Fim = erlang:monotonic_time(millisecond),
  Tempo = Fim - Inicio,

  io:format("~n====================================~n"),
  io:format("RESULTADO FINAL~n"),
  io:format("====================================~n"),
  io:format("Codigo: ~p~n", [MaiorGlobal#funcionario.codigo]),
  io:format("Nome: ~p~n", [MaiorGlobal#funcionario.nome]),
  io:format("Cidade: ~p~n", [MaiorGlobal#funcionario.cidade]),
  io:format("Maior salario: R$ ~.2f~n", [MaiorGlobal#funcionario.salario]),
  io:format("Processos utilizados: ~p~n", [NumProcessos]),
  io:format("Tempo de execucao: ~p ms~n", [Tempo]),
  io:format("====================================~n~n"),

  MaiorGlobal.

%% =====================================================
%% Fatiador de Binários Inteligente
%% Corta o byte array no número exato sem criar cópias na memória
%% =====================================================
fatiar_binario(Bin, NumProcessos) ->
  TamanhoTotal = byte_size(Bin),
  TamanhoAlvo = TamanhoTotal div NumProcessos,
  fatiar_aux(Bin, TamanhoAlvo, 0, NumProcessos, []).

fatiar_aux(Bin, _TamanhoAlvo, Offset, 1, Acum) ->
  %% O último processo pega tudo até o final do arquivo
  Pedaco = binary:part(Bin, Offset, byte_size(Bin) - Offset),
  lists:reverse([Pedaco | Acum]);

fatiar_aux(Bin, TamanhoAlvo, Offset, ProcessosRestantes, Acum) ->
  Alvo = Offset + TamanhoAlvo,
  if
    Alvo >= byte_size(Bin) ->
      fatiar_aux(Bin, TamanhoAlvo, Offset, 1, Acum);
    true ->
      %% Encontra o '\n' mais próximo para não cortar a linha no meio
      case binary:match(Bin, <<"\n">>, [{scope, {Alvo, byte_size(Bin) - Alvo}}]) of
        {PosQuebra, 1} ->
          TamanhoCorte = PosQuebra + 1 - Offset,
          Pedaco = binary:part(Bin, Offset, TamanhoCorte),
          fatiar_aux(Bin, TamanhoAlvo, PosQuebra + 1, ProcessosRestantes - 1, [Pedaco | Acum]);
        nomatch ->
          %% Se não houver mais \n, manda tudo o que sobrou
          fatiar_aux(Bin, TamanhoAlvo, Offset, 1, Acum)
      end
  end.

converter_linha_final(Linha, Salario) ->
  [CodigoBin, NomeBin, _, CidadeBin] = binary:split(Linha, <<",">>, [global]),
  #funcionario{
    codigo = binary_to_integer(string:trim(CodigoBin)),
    nome = string:trim(NomeBin),
    salario = Salario,
    cidade = string:trim(CidadeBin)
  }.

coletar(0, Resultados) -> Resultados;
coletar(N, Resultados) ->
  receive
    {resultado, MaiorSalario, LinhaVencedora} ->
      coletar(N - 1, [{MaiorSalario, LinhaVencedora} | Resultados])
  end.

vencedor([Primeiro | Resto]) ->
  lists:foldl(
    fun({Salario, Linha}, {MaiorAtual, LinhaAtual}) ->
      if Salario > MaiorAtual -> {Salario, Linha};
        true -> {MaiorAtual, LinhaAtual}
      end
    end,
    Primeiro,
    Resto
  ).