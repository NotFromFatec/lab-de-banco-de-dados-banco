package com.banco.agenciaBancaria.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Conta {
	private String codigo;
	private int agencia_codigo;
	private String data_abertura;
	private Double saldo;
	private String tipo_conta;
}
