﻿
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Banco')
BEGIN
    CREATE DATABASE Banco;
END;
GO

USE Banco;
GO

-- =============================================
-- ## LIMPEZA (DROP) DE OBJETOS EXISTENTES ##
-- Executar com cuidado! Remove tabelas e procedures existentes.
-- =============================================

-- Remover Constraints de Chave Estrangeira (FKs) primeiro para evitar erros ao dropar tabelas
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fk_cliente_conta_conta')
    ALTER TABLE cliente_conta DROP CONSTRAINT fk_cliente_conta_conta;
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fk_cliente_conta_cliente')
    ALTER TABLE cliente_conta DROP CONSTRAINT fk_cliente_conta_cliente;
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fk_conta_poupanca_conta')
    ALTER TABLE conta_poupanca DROP CONSTRAINT fk_conta_poupanca_conta;
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fk_conta_corrente_conta')
    ALTER TABLE conta_corrente DROP CONSTRAINT fk_conta_corrente_conta;
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fk_conta_agencia')
    ALTER TABLE conta DROP CONSTRAINT fk_conta_agencia;
GO

-- Remover Stored Procedures
IF OBJECT_ID('sp_agencia_criar', 'P') IS NOT NULL DROP PROCEDURE sp_agencia_criar;
IF OBJECT_ID('sp_agencia_ler', 'P') IS NOT NULL DROP PROCEDURE sp_agencia_ler;
IF OBJECT_ID('sp_agencia_atualizar', 'P') IS NOT NULL DROP PROCEDURE sp_agencia_atualizar;
IF OBJECT_ID('sp_agencia_deletar', 'P') IS NOT NULL DROP PROCEDURE sp_agencia_deletar;
GO
IF OBJECT_ID('sp_cliente_criar', 'P') IS NOT NULL DROP PROCEDURE sp_cliente_criar;
IF OBJECT_ID('sp_cliente_ler', 'P') IS NOT NULL DROP PROCEDURE sp_cliente_ler;
IF OBJECT_ID('sp_cliente_atualizar_senha', 'P') IS NOT NULL DROP PROCEDURE sp_cliente_atualizar_senha;
IF OBJECT_ID('sp_cliente_deletar', 'P') IS NOT NULL DROP PROCEDURE sp_cliente_deletar;
IF OBJECT_ID('sp_cliente_validar_login', 'P') IS NOT NULL DROP PROCEDURE sp_cliente_validar_login;
GO
IF OBJECT_ID('fn_calcular_digito_verificador', 'FN') IS NOT NULL DROP FUNCTION fn_calcular_digito_verificador;
IF OBJECT_ID('sp_conta_gerar_codigo', 'P') IS NOT NULL DROP PROCEDURE sp_conta_gerar_codigo;
IF OBJECT_ID('sp_conta_criar', 'P') IS NOT NULL DROP PROCEDURE sp_conta_criar;
IF OBJECT_ID('sp_conta_ler', 'P') IS NOT NULL DROP PROCEDURE sp_conta_ler;
IF OBJECT_ID('sp_conta_atualizar_dados', 'P') IS NOT NULL DROP PROCEDURE sp_conta_atualizar_dados;
IF OBJECT_ID('sp_conta_deletar', 'P') IS NOT NULL DROP PROCEDURE sp_conta_deletar; -- Geralmente não se deleta conta, mas para CRUD completo
IF OBJECT_ID('sp_conta_adicionar_companheiro', 'P') IS NOT NULL DROP PROCEDURE sp_conta_adicionar_companheiro;
IF OBJECT_ID('sp_conta_ler_detalhes', 'P') IS NOT NULL DROP PROCEDURE sp_conta_ler_detalhes;
GO

-- Remover Tabelas
IF OBJECT_ID('cliente_conta', 'U') IS NOT NULL DROP TABLE cliente_conta;
IF OBJECT_ID('conta_poupanca', 'U') IS NOT NULL DROP TABLE conta_poupanca;
IF OBJECT_ID('conta_corrente', 'U') IS NOT NULL DROP TABLE conta_corrente;
IF OBJECT_ID('conta', 'U') IS NOT NULL DROP TABLE conta;
IF OBJECT_ID('cliente', 'U') IS NOT NULL DROP TABLE cliente;
IF OBJECT_ID('agencia', 'U') IS NOT NULL DROP TABLE agencia;
GO

-- =============================================
-- ## CRIAÇÃO DAS TABELAS ##
-- =============================================

-- Tabela de Agências
CREATE TABLE agencia (
    codigo INT PRIMARY KEY IDENTITY(1000,1), -- Código sequencial para simplificar, a regra do doc é para conta.
    nome VARCHAR(100) NOT NULL,
    cep VARCHAR(9) NOT NULL, -- Formato '12345-678'
    cidade VARCHAR(100) NOT NULL
);
SELECT * FROM agencia
GO
PRINT 'Tabela agencia criada.';
GO

-- Tabela de Clientes
CREATE TABLE cliente (
    cpf VARCHAR(11) PRIMARY KEY, -- Armazenar apenas números
    nome VARCHAR(150) NOT NULL,
    data_primeira_conta DATE NULL, -- Pode ser nulo até ter a primeira conta
    senha VARCHAR(255) NOT NULL, -- Armazenar hash em produção real. Regra de 8 chars/3 numéricos validada na SP.
    -- CHECK (LEN(senha) >= 8) -- Validação básica, a SP fará a completa.
);
SELECT * FROM cliente
GO
PRINT 'Tabela cliente criada.';
GO

-- Tabela Base de Contas (Class Table Inheritance)
CREATE TABLE conta (
    codigo VARCHAR(50) PRIMARY KEY, -- Formato: agencia_codigo + 3_dig_cpf[+ 3_dig_cpf2] + dv
    agencia_codigo INT NOT NULL,
    data_abertura DATE NOT NULL DEFAULT GETDATE(),
    saldo DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    tipo_conta CHAR(1) NOT NULL, -- 'C' = Corrente, 'P' = Poupança
    CONSTRAINT chk_tipo_conta CHECK (tipo_conta IN ('C', 'P')),
    CONSTRAINT fk_conta_agencia FOREIGN KEY (agencia_codigo) REFERENCES agencia(codigo)
);
GO
PRINT 'Tabela conta criada.';
GO

-- Tabela Específica para Contas Correntes
CREATE TABLE conta_corrente (
    conta_codigo VARCHAR(50) PRIMARY KEY,
    limite_credito DECIMAL(15, 2) NOT NULL DEFAULT 500.00,
    CONSTRAINT fk_conta_corrente_conta FOREIGN KEY (conta_codigo) REFERENCES conta(codigo) ON DELETE CASCADE -- Se a conta base for deletada, deleta a específica
);
GO
PRINT 'Tabela conta_corrente criada.';
GO
-- Tabela Específica para Contas Poupança
CREATE TABLE conta_poupanca (
    conta_codigo VARCHAR(50) PRIMARY KEY,
    percentual_rendimento DECIMAL(5, 2) NOT NULL DEFAULT 1.00,
    dia_aniversario INT NOT NULL DEFAULT 10,
    CONSTRAINT chk_dia_aniversario CHECK (dia_aniversario BETWEEN 1 AND 31),
    CONSTRAINT fk_conta_poupanca_conta FOREIGN KEY (conta_codigo) REFERENCES conta(codigo) ON DELETE CASCADE -- Se a conta base for deletada, deleta a específica
);
GO
PRINT 'Tabela conta_poupanca criada.';
GO

-- Tabela de Ligação Cliente-Conta (Relacionamento N:M)
CREATE TABLE cliente_conta (
    cliente_cpf VARCHAR(11) NOT NULL,
    conta_codigo VARCHAR(50) NOT NULL,
    -- is_titular BIT NOT NULL DEFAULT 0, -- Poderia indicar o titular principal, mas a regra de código já implica isso.
    CONSTRAINT pk_cliente_conta PRIMARY KEY (cliente_cpf, conta_codigo),
    CONSTRAINT fk_cliente_conta_cliente FOREIGN KEY (cliente_cpf) REFERENCES cliente(cpf),
    CONSTRAINT fk_cliente_conta_conta FOREIGN KEY (conta_codigo) REFERENCES conta(codigo) ON DELETE CASCADE -- Se a conta for deletada, remove a ligação
);
GO
PRINT 'Tabela cliente_conta criada.';
GO

-- =============================================
-- ## FUNÇÕES AUXILIARES ##
-- =============================================

-- Função para calcular o dígito verificador conforme a regra especificada
-- Soma dos dígitos do RA / 5 -> parte inteira do resto da divisão (?)
-- Interpretação 1: MOD (Resto da divisão inteira) -> SUM % 5
-- Interpretação 2: FLOOR(SUM / 5) (Parte inteira da divisão)
-- A descrição "parte inteira do resto da divisão" é ambígua. Usarei MODULO (%), que é mais comum para DVs.
-- Se for a parte inteira da divisão, troque 'SUM % 5' por 'FLOOR(SUM / 5)'.
-- A função recebe a string base para cálculo (agencia+cpf[+cpf2])
-- =============================================
CREATE FUNCTION fn_calcular_digito_verificador (@base_calculo VARCHAR(MAX))
RETURNS INT
AS
BEGIN
    DECLARE @soma INT = 0;
    DECLARE @i INT = 1;
    DECLARE @len INT = LEN(@base_calculo);
    DECLARE @char CHAR(1);

    WHILE @i <= @len
    BEGIN
        SET @char = SUBSTRING(@base_calculo, @i, 1);
        -- Somar apenas se for um dígito numérico
        IF ISNUMERIC(@char) = 1
        BEGIN
            SET @soma = @soma + CAST(@char AS INT);
        END
        SET @i = @i + 1;
    END

    -- Retorna o resto da divisão da soma por 5
    RETURN @soma % 5;
END;
GO
PRINT 'Função fn_calcular_digito_verificador criada.';
GO

-- =============================================
-- ## STORED PROCEDURES - AGENCIA ##
-- =============================================

-- CRIAR Agencia
CREATE PROCEDURE sp_agencia_criar (
	@mensagem VARCHAR(200) OUTPUT,
    @nome VARCHAR(100),
    @cep VARCHAR(9),
    @cidade VARCHAR(100),
    @codigo_gerado INT OUTPUT -- Retorna o código da agência criada
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO agencia (nome, cep, cidade)
        VALUES (@nome, @cep, @cidade);

        SET @codigo_gerado = SCOPE_IDENTITY(); -- Obtém o último ID inserido nesta sessão
        SET @mensagem = 'Agência ' + @nome + ' criada com sucesso. Código: ' + CAST(@codigo_gerado AS VARCHAR);
    END TRY
    BEGIN CATCH
        SET @mensagem = 'Erro ao criar agência: ' + ERROR_MESSAGE();
        SET @codigo_gerado = -1; -- Indica erro
        -- THROW; -- Descomente para relançar o erro para a aplicação cliente
    END CATCH
    SET NOCOUNT OFF;
END;
GO
PRINT 'Stored Procedure sp_agencia_criar criada.';
GO

-- LER Agencia(s)
CREATE PROCEDURE sp_agencia_ler (
    @codigo INT = NULL -- Opcional: Se fornecido, lê apenas esta agência
)
AS
BEGIN
    SET NOCOUNT ON;
    IF @codigo IS NULL
        SELECT codigo, nome, cep, cidade FROM agencia ORDER BY nome;
    ELSE
        SELECT codigo, nome, cep, cidade FROM agencia WHERE codigo = @codigo;
    SET NOCOUNT OFF;
END;
GO
PRINT 'Stored Procedure sp_agencia_ler criada.';
GO

-- ATUALIZAR Agencia
CREATE PROCEDURE sp_agencia_atualizar (
	@mensagem VARCHAR(200) OUTPUT,
    @codigo INT,
    @nome VARCHAR(100),
    @cep VARCHAR(9),
    @cidade VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE agencia
        SET nome = @nome,
            cep = @cep,
            cidade = @cidade
        WHERE codigo = @codigo;

        IF @@ROWCOUNT = 0
            SET @mensagem = 'Erro: Agência com código ' + CAST(@codigo AS VARCHAR) + ' não encontrada.';
        ELSE
            SET @mensagem = 'Agência ' + CAST(@codigo AS VARCHAR) + ' atualizada com sucesso.';
    END TRY
    BEGIN CATCH
        SET @mensagem = 'Erro ao atualizar agência: ' + ERROR_MESSAGE();
        -- THROW;
    END CATCH
    SET NOCOUNT OFF;
END;
GO
PRINT 'Stored Procedure sp_agencia_atualizar criada.';
GO

-- DELETAR Agencia
CREATE PROCEDURE sp_agencia_deletar (
	@mensagem VARCHAR(200) OUTPUT,
    @codigo INT
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Verificar se existem contas associadas a esta agência
        IF EXISTS (SELECT 1 FROM conta WHERE agencia_codigo = @codigo)
        BEGIN
            SET @mensagem = 'Erro: Não é possível deletar a agência ' + CAST(@codigo AS VARCHAR) + ' pois ela possui contas associadas.';
            RETURN -1; -- Código de erro indicando falha por dependência
        END

        DELETE FROM agencia WHERE codigo = @codigo;

        IF @@ROWCOUNT = 0
            SET @mensagem = 'Erro: Agência com código ' + CAST(@codigo AS VARCHAR) + ' não encontrada.';
        ELSE
            SET @mensagem = 'Agência ' + CAST(@codigo AS VARCHAR) + ' deletada com sucesso.';

        RETURN 0; -- Sucesso

    END TRY
    BEGIN CATCH
        SET @mensagem = 'Erro ao deletar agência: ' + ERROR_MESSAGE();
        -- THROW;
        RETURN -99; -- Código de erro genérico
    END CATCH
    SET NOCOUNT OFF;
END;
GO
PRINT 'Stored Procedure sp_agencia_deletar criada.';
GO

-- =============================================
-- ## STORED PROCEDURES - CLIENTE ##
-- =============================================

-- CRIAR Cliente
CREATE PROCEDURE sp_cliente_criar (
	@mensagem VARCHAR(200) OUTPUT,
    @cpf VARCHAR(11),
    @nome VARCHAR(150),
    @senha VARCHAR(255)
    -- @data_primeira_conta DATE -- Removido, será atualizado ao criar a primeira conta
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validações
		IF @CPF = '00000000000' OR @CPF ='11111111111' OR @CPF = '22222222222' OR @CPF = '33333333333' OR
		@CPF = '44444444444' OR @CPF = '55555555555' OR @CPF = '66666666666' OR @CPF = '77777777777' OR
		@CPF = '88888888888' OR @CPF = '99999999999'
		BEGIN
			SET @mensagem = 'Erro: CPF inválido. Não pode conter 11 dígitos iguais'; RETURN;
		END
        IF LEN(ISNULL(@cpf, '')) <> 11 OR ISNUMERIC(@cpf) = 0
        BEGIN
            SET @mensagem = 'Erro: CPF inválido. Deve conter 11 dígitos numéricos.'; RETURN;
        END
        IF EXISTS (SELECT 1 FROM cliente WHERE cpf = @cpf)
        BEGIN
            SET @mensagem = 'Erro: CPF ' + @cpf + ' já cadastrado.'; RETURN;
        END
        IF LEN(ISNULL(@senha,'')) < 8
        BEGIN
             SET @mensagem = 'Erro: Senha deve ter pelo menos 8 caracteres.'; RETURN;
        END
        -- Validação simplificada para 3 números na senha (pode ser melhorada)
        IF @senha NOT LIKE '%[0-9]%[0-9]%[0-9]%'
        BEGIN
             SET @mensagem = 'Erro: Senha deve ter pelo menos 3 caracteres numéricos.'; RETURN;
        END


        INSERT INTO cliente (cpf, nome, senha, data_primeira_conta)
        VALUES (@cpf, @nome, @senha, NULL); -- Data da primeira conta inicia nula

        SET @mensagem = 'Cliente ' + @nome + ' (CPF: ' + @cpf + ') criado com sucesso.';
        RETURN; -- Sucesso

    END TRY
    BEGIN CATCH
        SET @mensagem =  'Erro ao criar cliente: ' + ERROR_MESSAGE();
        -- THROW;
        RETURN; -- Erro genérico
    END CATCH
    SET NOCOUNT OFF;
END;
GO
PRINT 'Stored Procedure sp_cliente_criar criada.';
GO

-- LER Cliente(s)
CREATE PROCEDURE sp_cliente_ler (
    @cpf VARCHAR(11) = NULL -- Opcional: Se fornecido, lê apenas este cliente
)
AS
BEGIN
    SET NOCOUNT ON;
    IF @cpf IS NULL
        SELECT cpf, nome, data_primeira_conta -- Não retornar a senha na leitura geral
        FROM cliente ORDER BY nome;
    ELSE
        SELECT cpf, nome, data_primeira_conta -- Não retornar a senha na leitura específica por CPF
        FROM cliente WHERE cpf = @cpf;
    SET NOCOUNT OFF;
END;
GO
PRINT 'Stored Procedure sp_cliente_ler criada.';
GO

-- ATUALIZAR Senha do Cliente (Único campo atualizável segundo as regras)
CREATE PROCEDURE sp_cliente_atualizar_senha (
	@mensagem VARCHAR(200) OUTPUT,
    @cpf VARCHAR(11),
    @senha_antiga VARCHAR(255),
    @nova_senha VARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @senha_atual VARCHAR(255);

        -- Verificar se cliente existe e senha antiga confere
        SELECT @senha_atual = senha FROM cliente WHERE cpf = @cpf;

        IF @senha_atual IS NULL
        BEGIN
            SET @mensagem = 'Erro: Cliente com CPF ' + @cpf + ' não encontrado.'; RETURN;
        END

        IF @senha_atual <> @senha_antiga -- Comparação direta (sem hash)
        BEGIN
            SET @mensagem = 'Erro: Senha antiga incorreta.'; RETURN;
        END

        -- Validar nova senha
        IF LEN(ISNULL(@nova_senha,'')) < 8
        BEGIN
             SET @mensagem =  'Erro: Nova senha deve ter pelo menos 8 caracteres.'; RETURN;
        END
         IF @nova_senha NOT LIKE '%[0-9]%[0-9]%[0-9]%'
        BEGIN
             SET @mensagem = 'Erro: Nova senha deve ter pelo menos 3 caracteres numéricos.'; RETURN;
        END

        -- Atualizar senha
        UPDATE cliente
        SET senha = @nova_senha
        WHERE cpf = @cpf;

        SET @mensagem = 'Senha do cliente ' + @cpf + ' atualizada com sucesso.';
        RETURN 0; -- Sucesso

    END TRY
    BEGIN CATCH
        PRINT 'Erro ao atualizar senha do cliente: ' + ERROR_MESSAGE();
        -- THROW;
        RETURN -99; -- Erro genérico
    END CATCH
    SET NOCOUNT OFF;
END;
GO
PRINT 'Stored Procedure sp_cliente_atualizar_senha criada.';
GO

-- DELETAR Cliente
CREATE PROCEDURE sp_cliente_deletar (
	@mensagem VARCHAR(200) OUTPUT,
    @cpf VARCHAR(11)
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Regra: "Clientes com contas conjuntas não podem ser excluídos da base."
        -- Verificar se o cliente participa de alguma conta que tenha MAIS DE UM titular.
        IF EXISTS (
            SELECT 1
            FROM cliente_conta cc
            WHERE cc.cliente_cpf = @cpf
              AND (SELECT COUNT(*) FROM cliente_conta cc2 WHERE cc2.conta_codigo = cc.conta_codigo) > 1
        )
        BEGIN
            SET @mensagem = 'Erro: Cliente ' + @cpf + ' não pode ser excluído pois possui conta(s) conjunta(s).';
            RETURN; -- Código de erro indicando falha por regra de negócio
        END

        -- Se chegou aqui, o cliente ou não tem contas ou só tem contas individuais.
        -- Verificar se o cliente possui alguma conta (individual, neste caso)
        IF EXISTS (SELECT 1 FROM cliente_conta WHERE cliente_cpf = @cpf)
        BEGIN
            -- Opcional: Decidir o que fazer com contas individuais órfãs.
            -- Opção 1: Impedir a exclusão.
            -- Opção 2: Excluir as contas individuais associadas (requer cuidado e confirmação).
            -- Opção 3: Permitir a exclusão do cliente, deixando as contas órfãs (não ideal).
            -- Vamos implementar a Opção 1 por segurança, já que a exclusão de conta não é uma operação comum.
            SET @mensagem = 'Erro: Cliente ' + @cpf + ' não pode ser excluído pois ainda possui conta(s) individual(is). Exclua as contas primeiro se necessário.';
            RETURN; -- Código de erro indicando falha por contas individuais existentes
        END

        -- Se não tem contas conjuntas e não tem contas individuais, pode excluir.
        DELETE FROM cliente WHERE cpf = @cpf;

        IF @@ROWCOUNT = 0
            SET @mensagem = 'Erro: Cliente com CPF ' + @cpf + ' não encontrado.';
        ELSE
            SET @mensagem = 'Cliente ' + @cpf + ' deletado com sucesso.';

        RETURN; -- Sucesso

    END TRY
    BEGIN CATCH
        SET @mensagem = 'Erro ao deletar cliente: ' + ERROR_MESSAGE();
        -- THROW;
        RETURN; -- Código de erro genérico
    END CATCH
    SET NOCOUNT OFF;
END;
GO
PRINT 'Stored Procedure sp_cliente_deletar criada.';
GO

-- VALIDAR Login do Cliente
CREATE PROCEDURE sp_cliente_validar_login (
    @cpf VARCHAR(11),
    @senha VARCHAR(255),
    @valido BIT OUTPUT,
    @nome_cliente VARCHAR(150) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @senha_bd VARCHAR(255);

    SELECT @senha_bd = senha, @nome_cliente = nome
    FROM cliente
    WHERE cpf = @cpf;

    IF @senha_bd IS NOT NULL AND @senha_bd = @senha -- Comparação direta (sem hash)
    BEGIN
        SET @valido = 1; -- Login válido
        PRINT 'Login validado para: ' + @nome_cliente;
    END
    ELSE
    BEGIN
        SET @valido = 0; -- Login inválido
        SET @nome_cliente = NULL;
    END
    SET NOCOUNT OFF;
END;
GO
PRINT 'Stored Procedure sp_cliente_validar_login criada.';
GO

-- =============================================
-- ## STORED PROCEDURES - CONTA ##
-- =============================================

-- CRIAR Conta (Procedimento principal que orquestra a criação)
CREATE PROCEDURE sp_conta_criar (
	@mensagem VARCHAR(200) OUTPUT,
    @agencia_codigo INT,
    @titular_cpf VARCHAR(11),
    @tipo_conta CHAR(1) -- 'C' ou 'P'
    -- @segundo_titular_cpf VARCHAR(11) = NULL -- Removido, adição de segundo titular é feita em SP separada sp_conta_adicionar_companheiro
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @codigo_conta VARCHAR(50);
    DECLARE @base_calculo_dv VARCHAR(100);
    DECLARE @digito_verificador INT;
    DECLARE @data_atual DATE = GETDATE();
    DECLARE @cliente_existe BIT = 0;
    DECLARE @data_primeira DATE;

    BEGIN TRY
        -- Validar parâmetros de entrada
        IF NOT EXISTS (SELECT 1 FROM agencia WHERE codigo = @agencia_codigo)
        BEGIN; SET @mensagem = 'Erro: Agência ' + CAST(@agencia_codigo AS VARCHAR) + ' não encontrada.'; RETURN -1; END;

        SELECT @cliente_existe = 1, @data_primeira = data_primeira_conta FROM cliente WHERE cpf = @titular_cpf;
        IF @cliente_existe = 0
        BEGIN; SET @mensagem = 'Erro: Cliente titular CPF ' + @titular_cpf + ' não encontrado.'; RETURN -2; END;

        IF @tipo_conta NOT IN ('C', 'P')
        BEGIN; SET @mensagem = 'Erro: Tipo de conta inválido. Selecione alguma das opções'; RETURN -3; END;

        -- Gerar código da conta
        -- Base = codigo_agencia + 3 ultimos digitos cpf titular
        SET @base_calculo_dv = CAST(@agencia_codigo AS VARCHAR) + RIGHT(@titular_cpf, 3);
        -- Calcular DV
        SET @digito_verificador = dbo.fn_calcular_digito_verificador(@base_calculo_dv);
        -- Código final = Base + DV
        SET @codigo_conta = @base_calculo_dv + CAST(@digito_verificador AS VARCHAR);

        -- Verificar se o código de conta já existe (colisão muito improvável, mas possível)
        IF EXISTS (SELECT 1 FROM conta WHERE codigo = @codigo_conta)
        BEGIN; SET @mensagem = 'Erro: Código de conta gerado (' + @codigo_conta + ') já existe. Tente novamente.'; RETURN -4; END;

        -- Iniciar transação para garantir atomicidade
        BEGIN TRANSACTION;
		SET @mensagem = 'Conta ' + @codigo_conta + ' (' + CASE @tipo_conta WHEN 'C' THEN 'Corrente' ELSE 'Poupança' END + ') criada com sucesso para o cliente ' + @titular_cpf + '.';
        -- Inserir na tabela base 'conta'
        INSERT INTO conta (codigo, agencia_codigo, data_abertura, saldo, tipo_conta)
        VALUES (@codigo_conta, @agencia_codigo, @data_atual, 0.00, @tipo_conta); -- Saldo inicial zerado

        -- Inserir na tabela específica (Corrente ou Poupança) com valores padrão
        IF @tipo_conta = 'C'
        BEGIN
            INSERT INTO conta_corrente (conta_codigo, limite_credito)
            VALUES (@codigo_conta, 500.00); -- Limite de crédito padrão 500,00
        END
        ELSE -- @tipo_conta = 'P'
        BEGIN
            INSERT INTO conta_poupanca (conta_codigo, percentual_rendimento, dia_aniversario)
            VALUES (@codigo_conta, 1.00, 10); -- Rendimento 1%, Dia aniversário padrão 10
        END

        -- Associar o cliente titular à conta na tabela de ligação
        INSERT INTO cliente_conta (cliente_cpf, conta_codigo)
        VALUES (@titular_cpf, @codigo_conta);

        -- Se for a primeira conta do cliente, atualizar data_primeira_conta
        IF @data_primeira IS NULL
        BEGIN
            UPDATE cliente
            SET data_primeira_conta = @data_atual
            WHERE cpf = @titular_cpf;
        END
        -- Confirmar a transação
        COMMIT TRANSACTION;
        RETURN 0; -- Sucesso

    END TRY
    BEGIN CATCH
        -- Desfazer a transação em caso de erro
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @mensagem = 'Erro ao criar conta: ' + ERROR_MESSAGE();
        -- THROW;
        RETURN -99; -- Erro genérico
    END CATCH
    SET NOCOUNT OFF;
END;
GO
PRINT 'Stored Procedure sp_conta_criar criada.';
GO

-- LER Conta(s) - Leitura básica, sem detalhes de tipo ou titulares
CREATE PROCEDURE sp_conta_ler (
    @codigo VARCHAR(50) = NULL, -- Opcional: Código da conta
    @cpf_cliente VARCHAR(11) = NULL -- Opcional: Listar contas de um cliente
)
AS
BEGIN
    SET NOCOUNT ON;
    IF @codigo IS NOT NULL
    BEGIN
        -- Ler uma conta específica pelo código
        SELECT c.codigo, c.agencia_codigo, a.nome AS nome_agencia, c.data_abertura, c.saldo, c.tipo_conta
        FROM conta c
        JOIN agencia a ON c.agencia_codigo = a.codigo
        WHERE c.codigo = @codigo;
    END
    ELSE IF @cpf_cliente IS NOT NULL
    BEGIN
        -- Ler todas as contas associadas a um cliente
        SELECT c.codigo, c.agencia_codigo, a.nome AS nome_agencia, c.data_abertura, c.saldo, c.tipo_conta
        FROM conta c
        JOIN agencia a ON c.agencia_codigo = a.codigo
        JOIN cliente_conta cc ON c.codigo = cc.conta_codigo
        WHERE cc.cliente_cpf = @cpf_cliente
        ORDER BY c.data_abertura;
    END
    ELSE
    BEGIN
        -- Ler todas as contas (geralmente não recomendado em produção real sem paginação)
        SELECT c.codigo, c.agencia_codigo, a.nome AS nome_agencia, c.data_abertura, c.saldo, c.tipo_conta
        FROM conta c
        JOIN agencia a ON c.agencia_codigo = a.codigo
        ORDER BY c.agencia_codigo, c.codigo;
    END
    SET NOCOUNT OFF;
END;
GO
PRINT 'Stored Procedure sp_conta_ler criada.';
GO

-- LER DETALHES da Conta (Incluindo dados específicos e titulares)
CREATE PROCEDURE sp_conta_ler_detalhes (
    @codigo VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Verifica se a conta existe
    IF NOT EXISTS (SELECT 1 FROM conta WHERE codigo = @codigo)
    BEGIN
        RAISERROR('Conta não encontrada', 16, 1);
        RETURN;
    END
    
    -- Retorna todos os dados em um único resultset
    SELECT
        c.codigo,
        c.agencia_codigo,
        a.nome AS nome_agencia,
        a.cep AS cep_agencia,
        a.cidade AS cidade_agencia,
        c.data_abertura,
        c.saldo,
        c.tipo_conta,
        ISNULL(cc.limite_credito, 0) AS limite_credito,
        ISNULL(cp.percentual_rendimento, 0) AS percentual_rendimento,
        ISNULL(cp.dia_aniversario, 0) AS dia_aniversario
    FROM conta c
    JOIN agencia a ON c.agencia_codigo = a.codigo
    LEFT JOIN conta_corrente cc ON c.codigo = cc.conta_codigo AND c.tipo_conta = 'C'
    LEFT JOIN conta_poupanca cp ON c.codigo = cp.conta_codigo AND c.tipo_conta = 'P'
    WHERE c.codigo = @codigo;
END;
GO
PRINT 'Stored Procedure sp_conta_ler_detalhes criada.';
GO
-- ATUALIZAR Dados da Conta (Apenas Saldo, Limite de Crédito, Percentual Rendimento)
CREATE PROCEDURE sp_conta_atualizar_dados (
	@mensagem VARCHAR(200) OUTPUT,
    @codigo VARCHAR(50),
    @saldo DECIMAL(15, 2) = NULL,
    @limite_credito DECIMAL(15, 2) = NULL,
    @percentual_rendimento DECIMAL(5, 2) = NULL,
    @dia_aniversario INT = NULL
) AS BEGIN
    SET NOCOUNT ON;
    DECLARE @tipo_conta CHAR(1);

    -- Verifica se a conta existe e pega o tipo
    SELECT @tipo_conta = tipo_conta FROM conta WHERE codigo = @codigo;

    IF @tipo_conta IS NULL BEGIN
        SET @mensagem = 'Erro: Conta com código ' + @codigo + ' não encontrada.'; RETURN -1;
    END
    BEGIN TRY 
	BEGIN TRANSACTION;

        -- Atualizar Saldo (se fornecido) na tabela base
        IF @saldo IS NOT NULL BEGIN
            UPDATE conta SET saldo = @saldo WHERE codigo = @codigo;
            SET @mensagem = 'Saldo da conta ' + @codigo + ' atualizado.';
        END

        -- Atualizar Limite de Crédito (se fornecido e for conta corrente)
        IF @limite_credito IS NOT NULL BEGIN
            IF @tipo_conta = 'C'
            BEGIN
                UPDATE conta_corrente SET limite_credito = @limite_credito WHERE conta_codigo = @codigo;
                SET @mensagem = 'Limite de crédito da conta ' + @codigo + ' atualizado para ' + CAST(@limite_credito AS VARCHAR) + '.';
            END
            ELSE
            BEGIN
                SET @mensagem = 'Aviso: Limite de crédito só pode ser atualizado para contas correntes. Nenhuma alteração feita no limite.';
            END
        END

        -- Atualizar Percentual de Rendimento (se fornecido e for conta poupan�a)
        IF @percentual_rendimento IS NOT NULL BEGIN
            IF @tipo_conta = 'P'
            BEGIN
                UPDATE conta_poupanca SET percentual_rendimento = @percentual_rendimento WHERE conta_codigo = @codigo;
                SET @mensagem = 'Percentual de rendimento da conta ' + @codigo + ' atualizado para ' + CAST(@percentual_rendimento AS VARCHAR) + '.';
            END
            ELSE
            BEGIN
                SET @mensagem = 'Aviso: Percentual de rendimento só pode ser atualizado para contas poupança. Nenhuma alteração feita no rendimento.';
            END
        END

        -- Atualizar Percentual de Rendimento (se fornecido e for conta poupan�a)
        IF @dia_aniversario IS NOT NULL BEGIN
            IF @tipo_conta = 'P'
            BEGIN
                UPDATE conta_poupanca SET dia_aniversario = @dia_aniversario WHERE conta_codigo = @codigo;
                SET @mensagem = 'Dia de aniversario da conta ' + @codigo + ' atualizado para ' + CAST(@dia_aniversario AS VARCHAR) + '.';
            END
            ELSE
            BEGIN
                SET @mensagem = 'Aviso: Dia de aniversário só pode ser atualizado para contas poupança. Nenhuma alteração feita no dia.';
            END
        END

        COMMIT TRANSACTION;
        RETURN 0; -- Sucesso

    END TRY BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SET @mensagem = 'Erro ao atualizar dados da conta: ' + ERROR_MESSAGE();
        -- THROW;
        RETURN -99; -- Erro gen�rico
    END CATCH
    SET NOCOUNT OFF;
END;
GO
PRINT 'Stored Procedure sp_conta_atualizar_dados criada.';
GO
-- DELETAR Conta (Geralmente não recomendado, mas para CRUD completo)
-- Esta SP deletará a conta da tabela base, e ON DELETE CASCADE cuidará das tabelas específicas e de ligação.
CREATE PROCEDURE sp_conta_deletar (
	@mensagem VARCHAR(200) OUTPUT,
    @codigo VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Adicionar verificações extras se necessário (ex: saldo zerado?)
        -- A FK com ON DELETE CASCADE já removerá de conta_corrente/conta_poupanca e cliente_conta.

        DELETE FROM conta WHERE codigo = @codigo;

        IF @@ROWCOUNT = 0
            SET @mensagem = 'Erro: Conta com código ' + @codigo + ' não encontrada.';
        ELSE
            SET @mensagem = 'Conta ' + @codigo + ' e associações deletadas com sucesso.';

        RETURN 0; -- Sucesso

    END TRY
    BEGIN CATCH
        SET @mensagem = 'Erro ao deletar conta: ' + ERROR_MESSAGE();
        -- THROW;
        RETURN -99; -- Código de erro genérico
    END CATCH
    SET NOCOUNT OFF;
END;
GO
PRINT 'Stored Procedure sp_conta_deletar criada.';
GO

-- =============================================
-- ## STORED PROCEDURES - REGRAS DE NEGÓCIO ESPECÍFICAS ##
-- =============================================

-- ADICIONAR Companheiro (segundo titular) a uma Conta Conjunta existente
CREATE PROCEDURE sp_conta_adicionar_companheiro (
	@mensagem VARCHAR(200) OUTPUT,
    @conta_codigo VARCHAR(50),       -- Código ATUAL da conta individual
    @companheiro_cpf VARCHAR(11),   -- CPF do novo titular a ser adicionado
    @autorizador_cpf VARCHAR(11),   -- CPF do titular existente (que está autorizando)
    @autorizador_senha VARCHAR(255) -- Senha do titular existente
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @valido BIT;
    DECLARE @nome_autorizador VARCHAR(150);
    DECLARE @num_titulares INT;
    DECLARE @saldo_conta DECIMAL(15, 2);
    DECLARE @data_abertura DATE;
    DECLARE @agencia_codigo INT;
    DECLARE @tipo_conta CHAR(1);
    DECLARE @base_calculo_dv VARCHAR(100);
    DECLARE @digito_verificador INT;
    DECLARE @novo_codigo_conta VARCHAR(50);
    DECLARE @limite_credito DECIMAL(15, 2);
    DECLARE @percentual_rendimento DECIMAL(5, 2);
    DECLARE @dia_aniversario INT;

    BEGIN TRY
        -- 1. Validar autorizador (login) - Assume sp_cliente_validar_login está correta (apesar do alerta de segurança)
        EXEC sp_cliente_validar_login @cpf = @autorizador_cpf, @senha = @autorizador_senha, @valido = @valido OUTPUT, @nome_cliente = @nome_autorizador OUTPUT;
        IF @valido = 0 BEGIN SET @mensagem = 'Erro: Login do autorizador (' + @autorizador_cpf + ') falhou.'; RETURN -1; END;

        -- 2. Verificar se o autorizador é titular da conta especificada (com o código ANTIGO)
        IF NOT EXISTS (SELECT 1 FROM cliente_conta WHERE conta_codigo = @conta_codigo AND cliente_cpf = @autorizador_cpf)
        BEGIN SET @mensagem = 'Erro: Autorizador (' + @autorizador_cpf + ') não é titular da conta ' + @conta_codigo + '.'; RETURN -2; END;

        -- 3. Verificar se a conta existe (com código ANTIGO) e obter dados
        SELECT @agencia_codigo = c.agencia_codigo, @tipo_conta = c.tipo_conta, @saldo_conta = c.saldo, @data_abertura = c.data_abertura
        FROM conta c WHERE c.codigo = @conta_codigo;
        IF @agencia_codigo IS NULL BEGIN SET @mensagem = 'Erro: Conta ' + @conta_codigo + ' não encontrada.'; RETURN -3; END;

        -- 4. Verificar se o companheiro existe
        IF NOT EXISTS (SELECT 1 FROM cliente WHERE cpf = @companheiro_cpf)
        BEGIN SET @mensagem = 'Erro: Cliente companheiro (CPF: ' + @companheiro_cpf + ') não encontrado.'; RETURN -4; END;

        -- 5. Verificar se o companheiro é o mesmo que o autorizador
        IF @companheiro_cpf = @autorizador_cpf BEGIN SET @mensagem = 'Erro: Companheiro não pode ser o mesmo que o autorizador.'; RETURN -5; END;

        -- 6. Verificar se o companheiro já está associado a esta conta (improvável se count=1, mas seguro)
        IF EXISTS (SELECT 1 FROM cliente_conta WHERE conta_codigo = @conta_codigo AND cliente_cpf = @companheiro_cpf)
        BEGIN SET @mensagem = 'Erro: Companheiro (CPF: ' + @companheiro_cpf + ') já é titular desta conta.'; RETURN -6; END;

        -- 7. Verificar número de titulares atuais (SÓ PODE ADICIONAR SE TIVER EXATAMENTE 1)
        SELECT @num_titulares = COUNT(*) FROM cliente_conta WHERE conta_codigo = @conta_codigo;
        IF @num_titulares <> 1 BEGIN SET @mensagem = 'Erro: Só é possível adicionar companheiro a uma conta individual (titulares atuais: ' + CAST(@num_titulares AS VARCHAR) + ').'; RETURN -7; END;

        -- 8. Regra do Saldo
        IF @saldo_conta <= 0 AND @data_abertura <> CONVERT(DATE, GETDATE())
        BEGIN SET @mensagem = 'Erro: Saldo (' + CAST(@saldo_conta AS VARCHAR) + ') menor/igual a zero e conta não criada hoje.'; RETURN -8; END;

        -- 9. Gerar o NOVO código da conta (Agencia + 3digCPFAutorizador + 3digCPFCompanheiro + DV)
        SET @base_calculo_dv = CAST(@agencia_codigo AS VARCHAR) + RIGHT(@autorizador_cpf, 3) + RIGHT(@companheiro_cpf, 3);
        SET @digito_verificador = dbo.fn_calcular_digito_verificador(@base_calculo_dv);
        SET @novo_codigo_conta = @base_calculo_dv + CAST(@digito_verificador AS VARCHAR);

        -- 10. Verificar colisão do NOVO código (muito raro, mas possível)
        IF EXISTS (SELECT 1 FROM conta WHERE codigo = @novo_codigo_conta)
        BEGIN SET @mensagem = 'Erro: Conflito ao gerar novo código (' + @novo_codigo_conta + '). Tente novamente.'; RETURN -10; END;

        -- 11. Iniciar Transação para a troca atômica
        BEGIN TRANSACTION;

        -- 12. Obter dados específicos da conta ANTIGA
        IF @tipo_conta = 'C' SELECT @limite_credito = limite_credito FROM conta_corrente WHERE conta_codigo = @conta_codigo;
        ELSE SELECT @percentual_rendimento = percentual_rendimento, @dia_aniversario = dia_aniversario FROM conta_poupanca WHERE conta_codigo = @conta_codigo;

        -- 13. Criar o NOVO registro na tabela 'conta'
        INSERT INTO conta (codigo, agencia_codigo, data_abertura, saldo, tipo_conta)
        VALUES (@novo_codigo_conta, @agencia_codigo, @data_abertura, @saldo_conta, @tipo_conta);

        -- 14. Criar o NOVO registro na tabela específica (CC ou CP)
        IF @tipo_conta = 'C' INSERT INTO conta_corrente (conta_codigo, limite_credito) VALUES (@novo_codigo_conta, @limite_credito);
        ELSE INSERT INTO conta_poupanca (conta_codigo, percentual_rendimento, dia_aniversario) VALUES (@novo_codigo_conta, @percentual_rendimento, @dia_aniversario);

        -- 15. Ligar AMBOS os titulares ao NOVO código de conta
        INSERT INTO cliente_conta (cliente_cpf, conta_codigo) VALUES (@autorizador_cpf, @novo_codigo_conta);
        INSERT INTO cliente_conta (cliente_cpf, conta_codigo) VALUES (@companheiro_cpf, @novo_codigo_conta);

        -- 16. DELETAR a conta ANTIGA (ON DELETE CASCADE cuidará das FKs em cliente_conta, conta_corrente/poupanca)
        DELETE FROM conta WHERE codigo = @conta_codigo;

        -- 17. Se for a primeira conta do companheiro, atualizar data
        IF NOT EXISTS (SELECT 1 FROM cliente_conta WHERE cliente_cpf = @companheiro_cpf AND conta_codigo <> @novo_codigo_conta) -- Verifica se ele não tem OUTRA conta
           AND (SELECT data_primeira_conta FROM cliente WHERE cpf = @companheiro_cpf) IS NULL
        BEGIN
            UPDATE cliente SET data_primeira_conta = @data_abertura WHERE cpf = @companheiro_cpf; -- Usa data abertura da conta conjunta
        END

        -- 18. Confirmar a transação
        COMMIT TRANSACTION;

        SET @mensagem = 'Cliente ' + @companheiro_cpf + ' adicionado com sucesso. Novo código da conta conjunta: ' + @novo_codigo_conta + '.';
        RETURN 0; -- Sucesso

    END TRY
    BEGIN CATCH
        -- Desfazer a transação em caso de erro
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @mensagem = 'Erro ao adicionar companheiro à conta ' + @conta_codigo + ': ' + ERROR_MESSAGE() + ' (Linha: ' + CAST(ERROR_LINE() AS VARCHAR) + ')';
        RETURN -99; -- Erro genérico
    END CATCH
    SET NOCOUNT OFF;
END;
GO
PRINT 'Stored Procedure sp_conta_adicionar_companheiro criada.';
GO

PRINT '=============================================================='
PRINT 'SCRIPT SQL EXECUTADO COM SUCESSO!'
PRINT 'Banco de dados "Banco" e seus objetos foram criados/atualizados.'
PRINT '=============================================================='
GO

-- =============================================
-- ## EXEMPLOS DE USO E TESTES ##
-- =============================================
/*
-- Exemplo: Criar Agência
DECLARE @ag_cod INT;
EXEC sp_agencia_criar @nome = 'Agência Central ZL', @cep = '08000-100', @cidade = 'São Paulo', @codigo_gerado = @ag_cod OUTPUT;
EXEC sp_agencia_criar @nome = 'Agência Vila Ré', @cep = '03660-010', @cidade = 'São Paulo', @codigo_gerado = @ag_cod OUTPUT;
GO

-- Exemplo: Ler Agências
EXEC sp_agencia_ler;
EXEC sp_agencia_ler @codigo = 1000; -- Substitua 1000 pelo código gerado se for diferente
GO

-- Exemplo: Criar Clientes
EXEC sp_cliente_criar @cpf = '11122233344', @nome = 'Fulano da Silva', @senha = 'senha123forte';
EXEC sp_cliente_criar @cpf = '55566677788', @nome = 'Ciclana de Souza', @senha = 'abc@123456';
EXEC sp_cliente_criar @cpf = '99988877766', @nome = 'Beltrano Oliveira', @senha = '987numero123';
GO

-- Exemplo: Ler Clientes
EXEC sp_cliente_ler;
EXEC sp_cliente_ler @cpf = '11122233344';
GO

-- Exemplo: Validar Login
DECLARE @is_valid BIT, @cli_nome VARCHAR(150);
EXEC sp_cliente_validar_login @cpf = '11122233344', @senha = 'senha123forte', @valido = @is_valid OUTPUT, @nome_cliente = @cli_nome OUTPUT;
SELECT @is_valid AS LoginValido, @cli_nome AS NomeCliente;
EXEC sp_cliente_validar_login @cpf = '11122233344', @senha = 'senha_errada', @valido = @is_valid OUTPUT, @nome_cliente = @cli_nome OUTPUT;
SELECT @is_valid AS LoginValido, @cli_nome AS NomeCliente;
GO

-- Exemplo: Criar Conta Corrente Individual para Fulano
DECLARE @conta_cod VARCHAR(50);
EXEC sp_conta_criar @agencia_codigo = 1000, @titular_cpf = '11122233344', @tipo_conta = 'C';
-- A SP retorna o código da conta criada na saída padrão ou via SELECT

-- Exemplo: Criar Conta Poupança Individual para Ciclana
EXEC sp_conta_criar @agencia_codigo = 1001, @titular_cpf = '55566677788', @tipo_conta = 'P';
GO

-- Exemplo: Ler contas do Fulano
EXEC sp_conta_ler @cpf_cliente = '11122233344';
GO

-- Exemplo: Ler detalhes de uma conta (substitua '1000344X' pelo código real gerado)
-- EXEC sp_conta_ler_detalhes @codigo = '1000344X';
GO

-- Exemplo: Atualizar Saldo e Limite da Conta Corrente (substitua '1000344X' pelo código real)
-- EXEC sp_conta_atualizar_dados @codigo = '1000344X', @saldo = 1500.75, @limite_credito = 750.00;
-- EXEC sp_conta_ler_detalhes @codigo = '1000344X';
GO

-- Exemplo: Adicionar Beltrano como companheiro na conta de Fulano (substitua '1000344X' pelo código real)
-- Assumindo que a conta 1000344X tem saldo > 0 ou foi criada hoje
-- EXEC sp_conta_adicionar_companheiro @conta_codigo = '1000344X', @companheiro_cpf = '99988877766', @autorizador_cpf = '11122233344', @autorizador_senha = 'senha123forte';
-- EXEC sp_conta_ler_detalhes @codigo = '1000344X'; -- Verificar se Beltrano foi adicionado
GO

-- Exemplo: Tentar adicionar um terceiro titular (deve falhar)
-- EXEC sp_conta_adicionar_companheiro @conta_codigo = '1000344X', @companheiro_cpf = '55566677788', @autorizador_cpf = '11122233344', @autorizador_senha = 'senha123forte';
GO

-- Exemplo: Tentar deletar Fulano (agora tem conta conjunta, deve falhar)
-- EXEC sp_cliente_deletar @cpf = '11122233344';
GO

-- Exemplo: Tentar deletar Ciclana (só tem conta individual, deve falhar pela regra de segurança implementada, a menos que a conta seja deletada primeiro)
-- EXEC sp_cliente_deletar @cpf = '55566677788';
GO

-- Exemplo: Deletar a conta poupança da Ciclana (substitua '1001788Y' pelo código real)
-- EXEC sp_conta_deletar @codigo = '1001788Y';
GO

-- Exemplo: Tentar deletar Ciclana novamente (agora sem contas, deve funcionar)
-- EXEC sp_cliente_deletar @cpf = '55566677788';
-- EXEC sp_cliente_ler @cpf = '55566677788'; -- Verificar se foi deletado
GO

*/