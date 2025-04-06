package com.banco.agenciaBancaria.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Cliente {
	private String cpf;
	private String nome;
	private String data_primeira_conta;
	private String senha;
}
