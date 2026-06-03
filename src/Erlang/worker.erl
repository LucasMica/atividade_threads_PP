-module(worker).
-export([buscar_maior/2]).

buscar_maior(Pai, BlocoBinario) ->
  {MaiorSalario, LinhaVencedora} = processar_chunk(BlocoBinario, 0, -1.0, <<>>),
  Pai ! {resultado, MaiorSalario, LinhaVencedora}.

processar_chunk(Chunk, Offset, MaiorAtual, LinhaAtual) ->
  case binary:match(Chunk, <<"\n">>, [{scope, {Offset, byte_size(Chunk) - Offset}}]) of
    {PosQuebra, 1} ->
      Comprimento = PosQuebra - Offset,
      %% Se a linha não for vazia, extrai o salário
      case Comprimento > 0 of
        true ->
          %% Isola exatamente a linha, sem os \r\n
          Linha = binary:part(Chunk, Offset, Comprimento),
          Salario = extrair_salario_rapido(Linha),

          if
            Salario > MaiorAtual ->
              processar_chunk(Chunk, PosQuebra + 1, Salario, Linha);
            true ->
              processar_chunk(Chunk, PosQuebra + 1, MaiorAtual, LinhaAtual)
          end;
        false ->
          %% Linha em branco, apenas continua
          processar_chunk(Chunk, PosQuebra + 1, MaiorAtual, LinhaAtual)
      end;

    nomatch ->
      %% Acabou o arquivo ou é a última linha sem \n no final
      Resto = binary:part(Chunk, Offset, byte_size(Chunk) - Offset),
      case byte_size(Resto) > 0 of
        true ->
          Salario = extrair_salario_rapido(Resto),
          if Salario > MaiorAtual -> {Salario, Resto};
            true -> {MaiorAtual, LinhaAtual}
          end;
        false ->
          {MaiorAtual, LinhaAtual}
      end
  end.

extrair_salario_rapido(Linha) ->
  case binary:match(Linha, <<",">>) of
    {Pos1, 1} ->
      Resto1 = binary:part(Linha, Pos1 + 1, byte_size(Linha) - Pos1 - 1),
      case binary:match(Resto1, <<",">>) of
        {Pos2, 1} ->
          Resto2 = binary:part(Resto1, Pos2 + 1, byte_size(Resto1) - Pos2 - 1),
          case binary:match(Resto2, <<",">>) of
            {Pos3, 1} ->
              SalarioBin = binary:part(Resto2, 0, Pos3),
              parse_salario(SalarioBin);
            nomatch -> 0.0
          end;
        nomatch -> 0.0
      end;
    nomatch -> 0.0
  end.

parse_salario(Binario) ->
  try binary_to_float(Binario) of
    Float -> Float
  catch
    error:badarg ->
      try binary_to_integer(string:trim(Binario)) * 1.0 of
        FloatInt -> FloatInt
      catch
        _:_ -> 0.0
      end
  end.