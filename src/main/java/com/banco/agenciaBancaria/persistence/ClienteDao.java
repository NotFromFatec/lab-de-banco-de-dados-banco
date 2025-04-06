package com.banco.agenciaBancaria.persistence;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.banco.agenciaBancaria.model.Cliente;

@Repository
public class ClienteDao implements ICrudDao<Cliente> {

	@Autowired
	private GenericDao gDao;

	@Override
	public String inserir(Cliente c) throws SQLException, ClassNotFoundException { // Método de inserir cliente no banco
																					// de dados
		Connection cn = gDao.getConnection();
		String sql = "{CALL sp_cliente_criar(?, ?, ?, ?)}"; // Constrói a chamada procedure de inserir no banco
		CallableStatement cs = cn.prepareCall(sql); // Chama a procedure de inserir no banco

		cs.registerOutParameter(1, Types.VARCHAR); // Registra parâmetro de saída que será nossa mensagem que retorna do
													// banco de dados
		// Define os parâmetros de entrada
		cs.setString(2, c.getCpf());
		cs.setString(3, c.getNome());
		cs.setString(4, c.getSenha());
		cs.execute();

		// Recebe a mensagem
		String mensagem = cs.getString(1);

		cs.close();
		cn.close();
		// Retorna nossa mensagem do banco de dados para a página
		return mensagem;
	}

	@Override
	public String atualizar(Cliente c) throws SQLException, ClassNotFoundException { // Método de atualizar cliente no
																						// banco de dados
		Connection cn = gDao.getConnection();
		String sql = "{CALL sp_cliente_atualizar(?, ?, ?, ?)}"; // Contrói a chamada de procedure que atualiza do banco
																// de dados
		CallableStatement cs = cn.prepareCall(sql);

		cs.registerOutParameter(1, Types.VARCHAR);
		// Define os parâmetros de entrada do cliente a ser atualizado
		cs.setString(2, c.getCpf());
		cs.setString(3, c.getNome());
		cs.setString(4, c.getSenha());
		cs.execute();

		String mensagem = cs.getString(1);

		cs.close();
		cn.close();
		return mensagem;
	}

	@Override
	public String excluir(Cliente c) throws SQLException, ClassNotFoundException { // Método de excluir cliente no
																					// banco de dados
		Connection cn = gDao.getConnection();
		String sql = "{CALL sp_cliente_deletar(?, ?)}"; // Contrói a chamada de procedure que exclui do banco
														// de dados
		CallableStatement cs = cn.prepareCall(sql);

		cs.registerOutParameter(1, Types.VARCHAR);
		// Define o parâmetro de entrada
		cs.setString(2, c.getCpf());
		cs.execute();

		String mensagem = cs.getString(1);

		cs.close();
		cn.close();
		return mensagem;
	}

	@Override
	public Cliente buscar(Cliente c) throws SQLException, ClassNotFoundException { // Método de buscar cliente
																					// específico no banco de dados
		Connection cn = gDao.getConnection();
		String sql = "{CALL sp_cliente_ler(?)}"; // Constrói a procedure que só recebe um parâmetro de busca
		PreparedStatement ps = cn.prepareStatement(sql);
		ps.setString(1, c.getCpf());
		ResultSet rs = ps.executeQuery();
		// Se houver algum resultado
		if (rs.next()) {
			// Setta os atributos retornados em nosso objeto de cliente
			c.setCpf(rs.getString("cpf"));
			c.setNome(rs.getString("nome"));
		}
		rs.close();
		ps.close();
		cn.close();

		// Retorna o cliente
		return c;
	}

	@Override
	public List<Cliente> listar() throws SQLException, ClassNotFoundException { // Método de buscar todos os clientes do
																				// banco de dados
		Connection cn = gDao.getConnection();
		String sql = "{CALL sp_cliente_ler}"; // Constrói a mesma procedure sem parâmetros para buscar todos
		CallableStatement cs = cn.prepareCall(sql);
		ResultSet rs = cs.executeQuery(); // Executa e obtém os resultados da query
		// Constrói nossa lista de clientes
		List<Cliente> clientes = new ArrayList<>();

		while (rs.next()) {
			// Cria o objeto de cliente para settar os atributos retornados
			Cliente Cliente = new Cliente();
			Cliente.setCpf(rs.getString("cpf"));
			Cliente.setNome(rs.getString("nome"));
			Cliente.setData_primeira_conta(rs.getString("data_primeira_conta"));

			clientes.add(Cliente); // Adiciona à lista de clientes
		}

		rs.close();
		cs.close();
		cn.close();

		return clientes; // Retorna a lista de clientes para apresentar na página
	}

	public int validarLogin(Cliente c) throws SQLException, ClassNotFoundException { // Método que valida o login do
																						// cliente na página
		Connection cn = gDao.getConnection();
		String sql = "{CALL sp_cliente_validar_login(?, ?, ?, ?)}"; // Constrói a procedure de validar o login no banco
																	// de dados
		CallableStatement cs = cn.prepareCall(sql);
		// Define os parâmetros de entrada
		cs.setString(1, c.getCpf());
		cs.setString(2, c.getSenha());
		cs.registerOutParameter(3, Types.BIT); // Registra parâmetro de saída para saber se a validação foi bem sucedida
		cs.registerOutParameter(4, Types.VARCHAR); // Nome do cliente para definirmos no objeto e mostrar mensagem de
													// "Bem vindo, + nome do cliente" na home
		cs.execute();

		int valido = cs.getInt(3); // Passa o número retornado para a variável, se for igual a 0 quer dizer que
									// senha e cpf estão corretos
		String nome = cs.getString(4); // Setta o nome do cliente na página
		c.setNome(nome);

		cs.close();
		cn.close();
		return valido; // Retorna para saber se cliente pode entrar na home ou não
	}

	public String trocarSenha(Cliente c, String senhaNova) throws SQLException, ClassNotFoundException { // Método que troca senha do login do
																											// cliente
		Connection cn = gDao.getConnection();
		String sql = "{call sp_cliente_atualizar_senha(?, ?, ?, ?)}"; // Constrói a procedure de troca de senha do login no banco
		CallableStatement cs = cn.prepareCall(sql);

		// Retorno da mensagem
		cs.registerOutParameter(1, Types.VARCHAR);

		// Define os parâmetros de entrada da senha antiga e a senha nova que o usuário quer
		cs.setString(2, c.getCpf());
		cs.setString(3, c.getSenha());
		cs.setString(4, senhaNova);
		cs.execute();

		// Recupera o valor retornado pela procedure
		String mensagem = cs.getString(1);
		cs.close();
		cn.close();
		// Retorna a mensagem da página
		return mensagem;
	}
}