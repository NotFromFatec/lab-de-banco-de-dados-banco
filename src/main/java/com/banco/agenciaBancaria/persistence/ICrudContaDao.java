package com.banco.agenciaBancaria.persistence;

import java.sql.SQLException;
import java.util.List;

import com.banco.agenciaBancaria.model.ContaCorrente;
import com.banco.agenciaBancaria.model.ContaPoupanca;

public interface ICrudContaDao<Conta> {
	public String inserir(Conta c, String cpf) throws SQLException, ClassNotFoundException;
    public String atualizar(Conta c, ContaCorrente cc, ContaPoupanca cp) throws SQLException, ClassNotFoundException;
    public String excluir(Conta c) throws SQLException, ClassNotFoundException;
    public Conta buscar(Conta c) throws SQLException, ClassNotFoundException;
    public List<Conta> listar(String cpf) throws SQLException, ClassNotFoundException;
}
