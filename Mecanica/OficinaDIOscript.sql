-- Esquema do banco de dados para a mecânica
CREATE DATABASE Mecanica;
USE Mecanica;

-- Tabela Cliente
CREATE TABLE Cliente (
    idCliente INT PRIMARY KEY,
    Nome VARCHAR(45) NOT NULL,
    Tipo ENUM('PJ', 'PF') NOT NULL,
    CPF_ou_CNPJ VARCHAR(45) UNIQUE NOT NULL,
    Contato VARCHAR(45),
    veiculo_idVeiculo INT,
    FOREIGN KEY (veiculo_idVeiculo) REFERENCES Veiculo(idVeiculo)
);

-- Tabela Veículo
CREATE TABLE Veiculo (
    idVeiculo INT PRIMARY KEY,
    Marca VARCHAR(45) NOT NULL,
    Nome VARCHAR(45) NOT NULL,
    Placa VARCHAR(45) UNIQUE NOT NULL,
    Ano INT NOT NULL
);

-- Tabela Equipe
CREATE TABLE Equipe (
    IDEquipe INT PRIMARY KEY,
    Nome VARCHAR(45) NOT NULL,
    Mecanicos INT
    FOREIGN key (Mecanicos) REFERENCES Mecanicos(idMecanicos)
);

-- Tabela Mecanicos
CREATE TABLE Mecanicos (
    idMecanicos INT PRIMARY KEY,
    Nome VARCHAR(45) NOT NULL,
    Endereco VARCHAR(45),
    Especialidade VARCHAR(45)
);

-- Tabela EquipeAvaliaVeiculo
CREATE TABLE EquipeAvaliaVeiculo (
    veiculo_idVeiculo INT,
    Equipe_IDEquipe INT,
    PRIMARY KEY (veiculo_idVeiculo, Equipe_IDEquipe),
    FOREIGN KEY (veiculo_idVeiculo) REFERENCES Veiculo(idVeiculo),
    FOREIGN KEY (Equipe_IDEquipe) REFERENCES Equipe(IDEquipe)
);

-- Tabela Serviço
CREATE TABLE Servico (
    idServico INT PRIMARY KEY,
    Tipo VARCHAR(45) NOT NULL,
    Descricao VARCHAR(45),
    Valor DECIMAL(10,2) NOT NULL,
    DataEstimadaDeConclusao DATE
);

-- Tabela Ordem de Serviço
CREATE TABLE OrdemDeServico (
    NroOS INT PRIMARY KEY,
    StatusOS VARCHAR(45) NOT NULL,
    DataDeEmissao DATETIME NOT NULL,
    Valor FLOAT NOT NULL,
    DataDeConclusao DATE,
    IDEquipe INT,
    IDVeiculo INT,
    FOREIGN KEY (IDEquipe) REFERENCES Equipe(IDEquipe),
    FOREIGN KEY (IDVeiculo) REFERENCES Veiculo(idVeiculo)
);

-- Tabela OrdemDeServico_has_Servico
CREATE TABLE OrdemDeServico_has_Servico (
    OrdemDeServico_NroOS INT,
    Servico_idServico INT,
    PRIMARY KEY (OrdemDeServico_NroOS, Servico_idServico),
    FOREIGN KEY (OrdemDeServico_NroOS) REFERENCES OrdemDeServico(NroOS),
    FOREIGN KEY (Servico_idServico) REFERENCES Servico(idServico)
);

-- Tabela Peças
CREATE TABLE Pecas (
    idPecas INT PRIMARY KEY,
    Descricao VARCHAR(45) NOT NULL,
    Valor FLOAT NOT NULL
);

-- Tabela OrdemDeServico_has_Pecas
CREATE TABLE OrdemDeServico_has_Pecas (
    OrdemDeServico_NroOS INT,
    Pecas_idPecas INT,
    PRIMARY KEY (OrdemDeServico_NroOS, Pecas_idPecas),
    FOREIGN KEY (OrdemDeServico_NroOS) REFERENCES OrdemDeServico(NroOS),
    FOREIGN KEY (Pecas_idPecas) REFERENCES Pecas(idPecas)
);

  ------------------------------------------------------------------------------------------------------------------------------------------------  

-- Inserção de dados para testes
INSERT INTO Cliente (idCliente, Nome, Tipo, CPF_ou_CNPJ, Contato, veiculo_idVeiculo) VALUES
(1, 'João Silva', 'PF', '12345678900', '11999999999', 1),
(2, 'Auto Center LTDA', 'PJ', '11222333000199', '11988888888', 2);

INSERT INTO Veiculo (idVeiculo, Marca, Nome, Placa, Ano) VALUES
(1, 'Toyota', 'Corolla', 'ABC1234', 2020),
(2, 'Honda', 'Civic', 'XYZ5678', 2019);

INSERT INTO Equipe (IDEquipe, Nome, Mecanicos) VALUES
(1, 'Equipe A', 3),
(2, 'Equipe B', 2);

INSERT INTO Mecanicos (idMecanicos, Nome, Endereco, Especialidade) VALUES
(1, 'Carlos Souza', 'Rua A, 100', 'Motor'),
(2, 'Mariana Lima', 'Rua B, 200', 'Pintura');

INSERT INTO Servico (idServico, Tipo, Descricao, Valor, DataEstimadaDeConclusao) VALUES
(1, 'Troca de óleo', 'Troca de óleo sintético', 150.00, '2024-06-10'),
(2, 'Alinhamento', 'Alinhamento e balanceamento', 200.00, '2024-06-12');

INSERT INTO OrdemDeServico (NroOS, StatusOS, DataDeEmissao, Valor, DataDeConclusao, IDEquipe, IDVeiculo) VALUES
(1, 'Aberta', '2024-06-05 10:00:00', 350.00, NULL, 1, 1);

INSERT INTO OrdemDeServico_has_Servico (OrdemDeServico_NroOS, Servico_idServico) VALUES
(1, 1),
(1, 2);

------------------------------------------------------------------------------------------------------------------------------------------------

-- Consultas SQL solicitadas

-- 1. Recuperações simples
SELECT * FROM Cliente;

-- 2. Filtro com WHERE
SELECT * FROM Veiculo WHERE Ano > 2019;

-- 3. Expressão para atributo derivado (cálculo de desconto)
SELECT idServico, Tipo, Valor, Valor * 0.9 AS ValorComDesconto FROM Servico;

-- 4. Ordenação com ORDER BY
SELECT * FROM Servico ORDER BY Valor DESC;

-- 5. Filtro com HAVING (total de serviços com valor médio acima de 150)
SELECT idServico, AVG(Valor) AS MediaValor FROM Servico GROUP BY idServico HAVING MediaValor > 150;

-- 6. Junção entre tabelas
SELECT OS.NroOS, C.Nome AS Cliente, V.Nome AS Veiculo, S.Tipo AS Servico, S.Valor
FROM OrdemDeServico OS
JOIN Cliente C ON OS.IDVeiculo = C.veiculo_idVeiculo
JOIN Veiculo V ON OS.IDVeiculo = V.idVeiculo
JOIN OrdemDeServico_has_Servico OSS ON OS.NroOS = OSS.OrdemDeServico_NroOS
JOIN Servico S ON OSS.Servico_idServico = S.idServico;