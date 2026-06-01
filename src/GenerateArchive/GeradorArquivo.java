package GenerateArchive;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Locale;
import java.util.Random;

public class GeradorArquivo {

    private static final String[] NOMES = {
            "João Silva", "Maria Souza", "Carlos Dias", "Ana Clara", "Pedro Paulo",
            "Lucia Gomes", "Marcos Oliveira", "Fernanda Santos", "Ricardo Lima",
            "Beatriz Costa", "Lucas Almeida", "Camila Ribeiro", "Gabriel Rodrigues",
            "Amanda Martins", "Rafael Carvalho"
    };

    private static final String[] CIDADES = {
            "São Paulo", "Rio de Janeiro", "Belo Horizonte", "Curitiba", "Porto Alegre",
            "Salvador", "Recife", "Fortaleza", "Brasília", "Manaus", "Florianópolis", "Belém"
    };

    public static void gerar(String nomeArquivo, int numLinhas, double salarioTeste) {
        File pastaTeste = new File("src" + File.separator + "Erlang");
        if (!pastaTeste.exists()) {
            pastaTeste.mkdirs();
        }

        if (!nomeArquivo.toLowerCase().endsWith(".txt")) {
            nomeArquivo += ".txt";
        }

        File arquivoFinal = new File(pastaTeste, nomeArquivo);
        Random random = new Random();

        int linhaOcultaDoTeste = random.nextInt(numLinhas) + 1;

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(arquivoFinal))) {

            for (int i = 1; i <= numLinhas; i++) {
                String linha;

                if (i == linhaOcultaDoTeste) {
                    linha = String.format(Locale.US, "%d,%s,%.2f,%s",
                            i, "FUNCIONARIO TESTE", salarioTeste, "CIDADE TESTE");
                }

                else {
                    String nome = NOMES[random.nextInt(NOMES.length)];
                    double salario = 1412.00 + (20000.00 - 1412.00) * random.nextDouble();
                    String cidade = CIDADES[random.nextInt(CIDADES.length)];

                    linha = String.format(Locale.US, "%d,%s,%.2f,%s", i, nome, salario, cidade);
                }

                writer.write(linha);
                writer.newLine();
            }

            System.out.println("Sucesso! Arquivo gerado em: " + arquivoFinal.getAbsolutePath());
            System.out.println("O 'FUNCIONARIO TESTE' com salário de R$ " + salarioTeste + " foi escondido na linha " + linhaOcultaDoTeste);

        } catch (IOException e) {
            System.err.println("Erro crítico ao tentar gravar o arquivo: " + e.getMessage());
        }
    }
}