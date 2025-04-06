package com.banco.agenciaBancaria.persistence;

import java.sql.SQLException;
import java.util.List;

public interface ICrudDao<T> {
	public String inserir(T T) throws SQLException, ClassNotFoundException;
    public String atualizar(T T) throws SQLException, ClassNotFoundException;
    public String excluir(T T) throws SQLException, ClassNotFoundException;
    public T buscar(T T) throws SQLException, ClassNotFoundException;
    public List<T> listar() throws SQLException, ClassNotFoundException;
}
