package com.banco.agenciaBancaria.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor

public class ContaPoupanca extends Conta {
	private Double percentual_rendimento;
	private int dia_aniversario;
}
