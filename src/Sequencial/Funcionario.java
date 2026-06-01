package Sequencial;

public class Funcionario {

    private int codigo;
    private String nome;
    private double salario;
    private String cidade;

    public Funcionario(String linhaTxt) {
        String[] partes = linhaTxt.split(",");
        this.codigo = Integer.parseInt(partes[0].trim());
        this.nome = partes[1].trim();
        this.salario = Double.parseDouble(partes[2].trim());
        this.cidade = partes[3].trim();
    }

    public double getSalario() { return salario; }
    public String getNome() { return nome; }
}
