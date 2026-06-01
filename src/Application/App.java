package Application;

import GenerateArchive.GeradorArquivo;
import Sequencial.SequencialSearch;

import java.io.File;

public class App {
    public static void main(String[] args) {

        GeradorArquivo.gerar("funcionarios.txt", 1000000, 123456.45);

        String path = "src" + File.separator + "Erlang" + File.separator + "funcionarios.txt";

        long t1 = SequencialSearch.start(path);

        System.out.printf("Tempo de execução da busca simples: %d\n", t1);

    }
}