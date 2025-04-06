package com.banco.agenciaBancaria.persistence;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.List;
import java.util.ArrayList;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.banco.agenciaBancaria.model.Agencia;
import com.banco.agenciaBancaria.model.Cliente;
import com.banco.agenciaBancaria.model.Conta;
import com.banco.agenciaBancaria.model.ContaCorrente;
import com.banco.agenciaBancaria.model.ContaPoupanca;

@Repository
public class ContaDao implements ICrudContaDao<Conta> {

	@Autowired
	private GenericDao gDao;

	@Override
	public String inserir(Conta c, String cpf) throws SQLException, ClassNotFoundException { // Método de inserir conta
																								// no banco de dados
		Connection cn = gDao.getConnection();
		String sql = "{CALL sp_conta_criar(?, ?, ?, ?)}"; // Constrói a chamada procedure de inserir no banco
		CallableStatement cs = cn.prepareCall(sql);

		cs.registerOutParameter(1, Types.VARCHAR); // Registra parâmetro de saída que será nossa mensagem que retorna do
													// banco de dados
		// Define os parâmetros de entrada
		cs.setInt(2, c.getAgencia_codigo());
		cs.setString(3, cpf);
		cs.setString(4, c.getTipo_conta());
		cs.execute();

		// Recebe a mensagem
		String mensagem = cs.getString(1);
		cs.close();
		cn.close();
		// Retorna nossa mensagem do banco de dados para a página
		return mensagem;
	}

	@Override
	public String atualizar(Conta c, ContaCorrente cc, ContaPoupanca cp) throws SQLException, ClassNotFoundException { // Método de atualizar no banco de dados
		Connection cn = gDao.getConnection();
		String sql = "{CALL sp_conta_atualizar_dados(?, ?, ?, ?, ?, ?)}"; // Constrói a procedure que irá passar os dois
																			// tipos de conta para que o banco de dados
																			// atualize dependendo do tipo
		CallableStatement cs = cn.prepareCall(sql);

		// Define os parâmetros de entrada
		cs.registerOutParameter(1, Types.VARCHAR); // Registra parâmetro de saída que será nossa mensagem que retorna do
													// banco de dados
		cs.setString(2, c.getCodigo());
		cs.setDouble(3, c.getSaldo());

		// Verifica se o limite de crédio não é nulo
		if (cc.getLimite_credito() != null) {
			cs.setDouble(4, cc.getLimite_credito());
		} else {
			cs.setNull(4, Types.DECIMAL); // Se for passa o parâmetro como nulo para seguir o fluxo certo no banco de
											// dados
		}

		// Verifica se o percentual de rendimento não é nulo
		if (cp.getPercentual_rendimento() != null) {
			cs.setDouble(5, cp.getPercentual_rendimento());
		} else {
			cs.setNull(5, Types.DECIMAL); // Se for passa o parâmetro como nulo para seguir o fluxo certo no banco de
											// dados
		}

		// Verifica se o dia de aniversário não é nulo
		if (cp.getDia_aniversario() != 0) {
			cs.setInt(6, cp.getDia_aniversario());
		} else {
			cs.setNull(6, Types.INTEGER); // Se for passa o parâmetro como nulo para seguir o fluxo certo no banco de
											// dados
		}

		cs.execute();

		String mensagem = cs.getString(1); // Pega a mensagem pra exibir na tela

		cs.close();
		cn.close();
		// Retorna nossa mensagem do banco de dados para a página
		return mensagem;
	}

	@Override
	public String excluir(Conta c) throws SQLException, ClassNotFoundException { // Método de excluir conta do banco de
																					// dados
		Connection cn = gDao.getConnection();
		String sql = "{CALL sp_conta_deletar(?, ?)}"; // Constrói a chamada procedure de deletar conta no banco
		CallableStatement cs = cn.prepareCall(sql);

		cs.registerOutParameter(1, Types.VARCHAR); // Registra parâmetro de saída que será nossa mensagem que retorna do
		// banco de dados
		// Define os parâmetros de entrada
		cs.setString(2, c.getCodigo());
		cs.execute();

		// Recebe a mensagem
		String mensagem = cs.getString(1);
		cs.close();
		cn.close();
		// Retorna nossa mensagem do banco de dados para a página
		return mensagem;
	}

	@Override
	public Conta buscar(Conta c) throws SQLException, ClassNotFoundException { // Método de buscar conta em específica
																				// no banco de dados
		Connection cn = gDao.getConnection();
		String sql = "{CALL sp_conta_ler(?, ?)}"; // Constrói a chamada procedure de buscar conta no banco
		PreparedStatement ps = cn.prepareStatement(sql);
		ps.setString(1, c.getCodigo());
		ps.setNull(2, Types.VARCHAR); // Setta o segundo parâmetro como nulo que é o cpf do cliente para que busque
										// apenas uma conta pelo código
		ResultSet rs = ps.executeQuery();
		// Se a busca retornar uma conta
		if (rs.next()) {
			// Setta os atributos da conta retornada em nosso objeto conta
			c.setCodigo(rs.getString("codigo"));
			c.setAgencia_codigo(rs.getInt("agencia_codigo"));
			c.setData_abertura(rs.getString("data_abertura"));
			c.setSaldo(rs.getDouble("saldo"));
			c.setTipo_conta(rs.getString("tipo_conta"));
		} else // Se não retornar nada na busca retorna null
			return null;
		rs.close();
		ps.close();
		cn.close();

		// Retorna nosso objeto
		return c;
	}

	@Override
	public List<Conta> listar(String cpf) throws SQLException, ClassNotFoundException { // Método de buscar todas as
																						// contas no banco de dados
		Connection cn = gDao.getConnection();
		String sql = "{CALL sp_conta_ler(?, ?)}";
		PreparedStatement ps = cn.prepareStatement(sql);
		ps.setNull(1, Types.VARCHAR); // Agora o código que é nulo, para que busque todas as contas vinculadas ao cpf
										// do cliente
		ps.setString(2, cpf);
		ResultSet rs = ps.executeQuery();
		// Cria nossa lista de contas
		List<Conta> contas = new ArrayList<>();
		while (rs.next()) {
			// Cria nosso objeto de conta para armazenar a busca
			Conta conta = new Conta();
			// Setta os atributos da conta retornada em nosso objeto conta
			conta.setCodigo(rs.getString("codigo"));
			conta.setAgencia_codigo(rs.getInt("agencia_codigo"));
			conta.setData_abertura(rs.getString("data_abertura"));
			conta.setSaldo(rs.getDouble("saldo"));
			conta.setTipo_conta(rs.getString("tipo_conta"));
			contas.add(conta); // Adiciona o objeto a nossa lista de contas
		}

		rs.close();
		ps.close();
		cn.close();
		// Retorna nossa lista para mostrar na página
		return contas;
	}

	public String consultarDetalhes(Conta conta, ContaCorrente cc, ContaPoupanca cp, Agencia a)
			throws SQLException, ClassNotFoundException { // Método de consultar detalhes da conta, que irá settar
															// parâmetros para os tipos de conta e pra agencia
		Connection cn = gDao.getConnection();
		String sql = "{CALL sp_conta_ler_detalhes(?)}"; // Constrói a chamada da procedure que só recebe o código da conta
		CallableStatement cs = cn.prepareCall(sql);
		cs.setString(1, conta.getCodigo());

		ResultSet rs = cs.executeQuery();
		
		// Se encontrar a conta
		if (rs.next()) {
			// Preenche os dados da agência
			if (a != null) {
				a.setNome(rs.getString("nome_agencia"));
				a.setCep(rs.getString("cep_agencia"));
				a.setCodigo(rs.getInt("agencia_codigo"));
				a.setCidade(rs.getString("cidade_agencia"));
			}

			// Preenche os dados específicos conforme o tipo de conta
			if (conta.getTipo_conta().equals("C")) {
				cc.setLimite_credito(rs.getDouble("limite_credito"));
			} else {
				cp.setDia_aniversario(rs.getInt("dia_aniversario"));
				cp.setPercentual_rendimento(rs.getDouble("percentual_rendimento"));
			}
		} else {
			return "Erro: Conta não encontrada"; // Retorna a mensagem para a página
		}

		rs.close();
		cs.close();
		cn.close();
		return null; // Se não houver erros retorna null
	}

	public String contaConjunta(Conta conta, Cliente cliente, String cpf) throws SQLException, ClassNotFoundException { // Método de adicionar
																														// Companheiro a conta conjunta
		Connection cn = gDao.getConnection();
		String sql = "{CALL sp_conta_adicionar_companheiro(?, ?, ?, ?, ?)}"; // Constrói a chamada da procedure de adicionar companheiro
		CallableStatement cs = cn.prepareCall(sql);

		cs.registerOutParameter(1, Types.VARCHAR); // Registra parâmetro de saída que será nossa mensagem que retorna do
		// banco de dados
		// Define os parâmetros de entrada
		cs.setString(2, conta.getCodigo());
		cs.setString(3, cpf);
		cs.setString(4, cliente.getCpf());
		cs.setString(5, cliente.getSenha());
		cs.execute();

		String mensagem = cs.getString(1);

		cs.close();
		cn.close();
		// Retorna nossa mensagem do banco de dados para a página
		return mensagem;
	}
}
