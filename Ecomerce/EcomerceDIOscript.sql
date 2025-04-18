
-- Criação do banco de dados
CREATE DATABASE Ecommerce;
USE Ecommerce;

-- Tabela Cliente
CREATE TABLE Cliente (
    idCliente INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(45) NOT NULL,
    Identificacao VARCHAR(45) UNIQUE NOT NULL,
    Tipo ENUM('PJ', 'PF') NOT NULL,
    CHECK (Tipo IN ('PJ', 'PF')),
	FOREIGN KEY (idEndereco) REFERENCES Endereco(idEndereco)
);

-- Tabela Endereço
CREATE TABLE Endereco (
    idEndereco INT AUTO_INCREMENT PRIMARY KEY,
    Logradouro VARCHAR(45) NOT NULL,
    Numero VARCHAR(10) NOT NULL,
    Bairro VARCHAR(45) NOT NULL,
    Cidade VARCHAR(45) NOT NULL,
    CEP VARCHAR(8) NOT NULL,
    CONSTRAINT chk_cep CHECK (CHAR_LENGTH(CEP) = 8)
);

-- Tabela Pedido
CREATE TABLE Pedido (
    idPedido INT AUTO_INCREMENT PRIMARY KEY,
    StatusPedido enum("cancelado", "Em andamento", "Confirmado") NOT NULL default "Em andamento",
    Descricao VARCHAR(255) NOT NULL,
    Cliente_idCliente INT NOT NULL,
    Frete FLOAT NOT NULL CHECK (Frete >= 0),
    pagamento bool default false,
    FOREIGN KEY (Cliente_idCliente) REFERENCES Cliente(idCliente)
);

-- Tabela Fornecedor
CREATE TABLE Fornecedor (
    idFornecedor INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(45) NOT NULL,
    RazaoSocial VARCHAR(45) NOT NULL,
    CNPJ VARCHAR(15) UNIQUE NOT NULL,
    contato varchar(20) not null, 
    CONSTRAINT chk_cnpj CHECK (CHAR_LENGTH(CNPJ) = 14)
);
-- Tabela Vendedor
CREATE TABLE Vendedor (
    idVendedor INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(45) NOT NULL,
    CNPJ VARCHAR(15),
    CPF varchar (9),
    Email VARCHAR(100) UNIQUE NOT NULL,
    Telefone VARCHAR(15) NOT NULL,
    Endereço varchar(255),
    CONSTRAINT chk_cnpj_vendedor CHECK (CHAR_LENGTH(CNPJ) = 14),
	CONSTRAINT chk_cpf_vendedor CHECK (CHAR_LENGTH(CPF) = 11)

)

-- Tabela Produtos
-- size = dimensão do produto
CREATE TABLE Produtos (
    idProdutos INT AUTO_INCREMENT PRIMARY KEY,
    Pname varchar(45) not null, 
    Categoria VARCHAR(45) NOT NULL,
    Valor DECIMAL(10,2) NOT NULL CHECK (Valor > 0),
    Descricao VARCHAR(255) NOT NULL,
    ProdutoSKU VARCHAR(45) UNIQUE NOT NULL
    Avaliação float,
    Size varchar(15)
    
);
-- Tabela Produto_vendedor
CREATE TABLE Vendedor_has_Produtos (
    idVendedorProduto INT AUTO_INCREMENT PRIMARY KEY,
    Vendedor_idVendedor INT NOT NULL,
    Produtos_idProdutos INT NOT NULL,
    PrecoVenda DECIMAL(10,2) NOT NULL CHECK (PrecoVenda > 0),
    UNIQUE (Vendedor_idVendedor, Produtos_idProdutos),
    FOREIGN KEY (Vendedor_idVendedor) REFERENCES Vendedor(idVendedor),
    FOREIGN KEY (Produtos_idProdutos) REFERENCES Produtos(idProdutos)
);
-- Tabela Estoque
CREATE TABLE Estoque (
    idEstoque INT AUTO_INCREMENT PRIMARY KEY,
    Local VARCHAR(45) NOT NULL
);

-- Tabela Produtos_has_estoque
CREATE TABLE Produtos_has_estoque (
    idProdutoNoEstoque INT AUTO_INCREMENT PRIMARY KEY,
    Produtos_idProdutos INT NOT NULL,
    Estoque_idEstoque INT NOT NULL,
    Quantidade INT NOT NULL CHECK (Quantidade >= 0) default 0, 
    FOREIGN KEY (Produtos_idProdutos) REFERENCES Produtos(idProdutos),
    FOREIGN KEY (Estoque_idEstoque) REFERENCES Estoque(idEstoque)
);

-- Tabela Pagamento
CREATE TABLE Pagamento (
    idPagamento INT AUTO_INCREMENT PRIMARY KEY,
    Status ENUM('Aprovado', 'Pendente', 'Cancelado') NOT NULL,
    Valor DECIMAL(10,2) NOT NULL CHECK (Valor >= 0),
    Data TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Pedido_idPedido INT NOT NULL,
    FOREIGN KEY (Pedido_idPedido) REFERENCES Pedido(idPedido)
);

-- Tabela Método de Pagamento
CREATE TABLE MetodoPagamento (
    idMetodoPagamento INT AUTO_INCREMENT PRIMARY KEY,
    Metodo ENUM('Cartão de Crédito', 'Boleto', 'Pix', 'Transferência Bancária')NOT NULL
);

-- Tabela Entrega
CREATE TABLE Entrega (
    idEntrega INT AUTO_INCREMENT PRIMARY KEY,
    Cliente_idCliente INT NOT NULL,
    Pedido_idPedido INT NOT NULL,
    CodigoRastreamento VARCHAR(45) UNIQUE NOT NULL,
    Status ENUM('Enviado', 'Em trânsito', 'Entregue') NOT NULL,
    DataEnvio DATETIME NOT NULL,
    DataEntregaPrevista DATE NOT NULL,
    DataEntregaReal DATETIME,
    FOREIGN KEY (Cliente_idCliente) REFERENCES Cliente(idCliente),
    FOREIGN KEY (Pedido_idPedido) REFERENCES Pedido(idPedido)
);


-- Inserção de dados fictícios para testes
INSERT INTO Cliente (Nome, Identificacao, Tipo) VALUES ('Empresa X', '12345678000199', 'PJ');
INSERT INTO Cliente (Nome, Identificacao, Tipo) VALUES ('João Silva', '12345678901', 'PF');

INSERT INTO Fornecedor (Nome, RazaoSocial, CNPJ) VALUES ('Fornecedor A', 'Fornecedor A Ltda', '98765432000112');

INSERT INTO Produtos (Categoria, Valor, Descricao, ProdutoSKU) VALUES ('Eletrônicos', 1500.00, 'Smartphone Modelo X', 'ELE-001');

INSERT INTO Estoque (Local) VALUES ('Centro de Distribuição SP');

INSERT INTO Produtos_has_estoque (Produtos_idProdutos, Estoque_idEstoque, Quantidade) VALUES (1, 1, 100);

INSERT INTO Pedido (StatusPedido, Descricao, Cliente_idCliente, Frete) VALUES ('Processando', 'Compra de um smartphone', 2, 20.00);

INSERT INTO Pagamento (Status, Valor, Pedido_idPedido) VALUES ('Aprovado', 1520.00, 1);

INSERT INTO Entrega (Cliente_idCliente, Pedido_idPedido, CodigoRastreamento, Status, DataEnvio, DataEntregaPrevista) VALUES (2, 1, 'BR123456789', 'Em trânsito', NOW(), DATE_ADD(NOW(), INTERVAL 5 DAY));

-- Consultas

-- Quantos pedidos foram feitos por cada cliente?
SELECT Cliente.Nome, COUNT(Pedido.idPedido) AS TotalPedidos
FROM Cliente
LEFT JOIN Pedido ON Cliente.idCliente = Pedido.Cliente_idCliente
GROUP BY Cliente.Nome;

-- Algum vendedor também é fornecedor?
SELECT F.Nome AS Fornecedor, V.Nome AS Vendedor
FROM Fornecedor F
JOIN Vendedor V ON F.Nome = V.Nome;

-- Relação de produtos, fornecedores e estoques
SELECT P.Descricao, F.Nome AS Fornecedor, E.Local AS Estoque, PHE.Quantidade
FROM Produtos P
JOIN Produtos_has_estoque PHE ON P.idProdutos = PHE.Produtos_idProdutos
JOIN Estoque E ON PHE.Estoque_idEstoque = E.idEstoque
JOIN Fornecedor F ON F.idFornecedor = PHE.Produtos_idProdutos;

-- Relação de nomes dos fornecedores e nomes dos produtos
SELECT F.Nome AS Fornecedor, P.Descricao AS Produto
FROM Fornecedor F, Produtos P;

-- Relação de vendedores e produtos
SELECT V.Nome AS Vendedor, P.Descricao AS Produto, VHP.PrecoVenda
FROM Vendedor V
JOIN Vendedor_has_Produtos VHP ON V.idVendedor = VHP.Vendedor_idVendedor
JOIN Produtos P ON VHP.Produtos_idProdutos = P.idProdutos;

-- Recuperação simples com SELECT
SELECT * FROM Cliente;

-- Filtros com WHERE
SELECT * FROM Pedido WHERE StatusPedido = 'Confirmado';

-- Expressão para gerar atributo derivado (total com frete)
SELECT idPedido, (SUM(Preco * Quantidade) + Frete) AS TotalPedido 
FROM ItemPedido
JOIN Pedido ON Pedido.idPedido = ItemPedido.Pedido_idPedido
GROUP BY idPedido;

-- Ordenação dos dados com ORDER BY
SELECT * FROM Cliente ORDER BY Nome ASC;

-- Condições de filtros aos grupos com HAVING
SELECT Cliente_idCliente, COUNT(idPedido) AS TotalPedidos
FROM Pedido
GROUP BY Cliente_idCliente
HAVING COUNT(idPedido) > 5;

-- Junção entre tabelas
SELECT Cliente.Nome, Pedido.idPedido, Pedido.StatusPedido
FROM Cliente
JOIN Pedido ON Cliente.idCliente = Pedido.Cliente_idCliente;

