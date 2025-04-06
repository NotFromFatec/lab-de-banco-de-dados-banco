package com.banco.agenciaBancaria.persistence;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.banco.agenciaBancaria.model.Agencia;

@Repository
public class AgenciaDao implements ICrudDao<Agencia> {

	@Autowired
	private GenericDao gDao;

	@Override
	public String inserir(Agencia a) throws SQLException, ClassNotFoundException { // Método de inserir agência no banco
																					// de dados
		// Realiza a conexão com o banco de dados
		Connection cn = gDao.getConnection();
		// Constrói a chamada de procedure em uma string
		String sql = "{CALL sp_agencia_criar(?, ?, ?, ?, ?)}";
		// Chama a procedure
		CallableStatement cs = cn.prepareCall(sql);

		cs.registerOutParameter(1, Types.VARCHAR); // Registra parâmetro de saída que será nossa mensagem de exibição na
													// página
		// Passa todos os atributos do objeto para guardar no banco de dados
		cs.setString(2, a.getNome());
		cs.setString(3, a.getCep());
		cs.setString(4, a.getCidade());
		cs.registerOutParameter(5, Types.INTEGER);
		cs.execute();

		// Recebe a mensagem de retorno do banco de dados
		String mensagem = cs.getString(1);
		cs.close();
		cn.close(); // Fecha conexão e a chamada da procedure
		// Retorna a mensagem para mostrar na página
		return mensagem;
	}

	@Override
	public String atualizar(Agencia a) throws SQLException, ClassNotFoundException { // Método de atualizar agência no
																						// banco de dados
		Connection cn = gDao.getConnection();
		String sql = "{CALL sp_agencia_atualizar(?, ?, ?, ?, ?)}";
		CallableStatement cs = cn.prepareCall(sql);
		cs.registerOutParameter(1, Types.VARCHAR); // Registra parâmetro de saída que será nossa mensagem de exibição na
													// página
		// Passa todos os atributos do objeto para atualizar no banco de dados
		cs.setInt(2, a.getCodigo());
		cs.setString(3, a.getNome());
		cs.setString(4, a.getCep());
		cs.setString(5, a.getCidade());
		cs.execute();

		String mensagem = cs.getString(1);
		cs.close();
		cn.close();
		// Retorna a mensagem para mostrar na página
		return mensagem;
	}

	@Override
	public String excluir(Agencia a) throws SQLException, ClassNotFoundException { // Método de excluir agência no
																					// banco de dados
		Connection cn = gDao.getConnection();
		String sql = "{CALL sp_agencia_deletar(?, ?)}";
		CallableStatement cs = cn.prepareCall(sql);
		cs.registerOutParameter(1, Types.VARCHAR);
		// Passa código da agência que será excluída do banco de dados
		cs.setInt(2, a.getCodigo());
		cs.execute();

		String mensagem = cs.getString(1);
		cs.close();
		cn.close();
		return mensagem;
	}

	@Override
	public List<Agencia> listar() throws SQLException, ClassNotFoundException { // Método de listar agências do
																				// banco de dados
		Connection cn = gDao.getConnection();
		String sql = "{CALL sp_agencia_ler}"; // Procedure em parâmetros para buscar todas que existem no banco
		CallableStatement cs = cn.prepareCall(sql);
		ResultSet rs = cs.executeQuery(); // Executa e obtém os resultados da query
		// Cria nossa lista de agências
		List<Agencia> agencias = new ArrayList<>();

		// Enquanto houver resultados do banco de dados
		while (rs.next()) {
			// Cria objeto de agência para cada resultado retornado
			Agencia agencia = new Agencia();
			// Setta todos os atributos no objeto da agência retornada
			agencia.setCodigo(rs.getInt("codigo"));
			agencia.setNome(rs.getString("nome"));
			agencia.setCep(rs.getString("cep"));
			agencia.setCidade(rs.getString("cidade"));

			agencias.add(agencia); // Adiciona à lista de agências
		}

		rs.close();
		cs.close();
		cn.close();

		return agencias; // Retorna a lista de agências para apresentar na página
	}

	@Override
	public Agencia buscar(Agencia a) throws SQLException, ClassNotFoundException { // Método de buscar agência
																					// específica do banco de dados
		Connection cn = gDao.getConnection();
		String sql = "{CALL sp_agencia_ler(?)}"; // Buscar uma agência em específico
		CallableStatement cs = cn.prepareCall(sql);
		cs.setInt(1, a.getCodigo());
		ResultSet rs = cs.executeQuery(); // Executa e obtém os resultados da query
		Agencia agencia = new Agencia();

		if (rs.next()) {
			// Passar os parâmetros para o objeto agência
			agencia.setCodigo(rs.getInt("codigo"));
			agencia.setNome(rs.getString("nome"));
			agencia.setCep(rs.getString("cep"));
			agencia.setCidade(rs.getString("cidade"));
		}

		rs.close();
		cs.close();
		cn.close();

		return agencia; // Retorna a agência buscada
	}

}
