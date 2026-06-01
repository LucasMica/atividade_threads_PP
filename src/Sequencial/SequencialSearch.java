package Sequencial;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class SequencialSearch {

    public static long start(String path) {

        long begin = System.currentTimeMillis();

        double maior = 0.00;

        List<String> todasAsLinhas = new ArrayList<>();

        try (BufferedReader br = new BufferedReader(new FileReader(path))) {
            String linha;
            linha = br.readLine();

            while (linha != null) {
                todasAsLinhas.add(linha);
                linha = br.readLine();
            }

        } catch (IOException e) {
            throw new RuntimeException(e.getMessage());
        }

        for (String linha : todasAsLinhas) {
            if (linha.trim().isEmpty()) continue;
            try {
                Funcionario atual = new Funcionario(linha);
                if (maior == 0.00 || atual.getSalario() > maior) {
                    maior = atual.getSalario();
                }
            } catch (Exception e) {
                throw new LineException(e.getMessage());
            }
        }

            System.out.printf("O maior valor de salário encontrado foi: %.2f\n", maior);

            long end = System.currentTimeMillis();

            return end - begin;
    }
}
