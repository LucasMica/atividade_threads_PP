# Trabalho Prático II - Processamento Paralelo

**Alunos:**

* Gustavo Trevizani
* Lucas de Oliveira Michaelsen
* Lucas de Oliveira Santos

## Descrição

Este projeto apresenta um experimento comparando uma implementação sequencial em Java com uma implementação paralela em Erlang para localizar o maior salário em um arquivo contendo 1.000.000 de registros.

A implementação paralela utiliza o modelo Master-Worker e comunicação por troca de mensagens.

## Execução

### Versão Java

Executar a classe:

```text
Application.App
```

A aplicação gera automaticamente o arquivo de entrada e realiza a busca sequencial.

### Versão Erlang

Acesse a pasta:

```text
src/Erlang
```

Abra o terminal Erlang:

```text
erl
```

Carregue o módulo:

```erlang
l(main).
```

Execute o experimento:

```erlang
main:start("funcionarios.txt",4).
```

Para os testes realizados no relatório, também podem ser utilizados:

```erlang
main:start("funcionarios.txt",1).
main:start("funcionarios.txt",2).
main:start("funcionarios.txt",4).
main:start("funcionarios.txt",8).
main:start("funcionarios.txt",16).
```

## Tecnologias utilizadas

* Java
* Erlang/OTP
* Modelo Actor
* Paralelismo Master-Worker
