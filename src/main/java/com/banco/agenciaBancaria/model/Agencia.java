package com.banco.agenciaBancaria.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Agencia {
	private int codigo;
	private String nome;
	private String cep;
	private String cidade;
}
