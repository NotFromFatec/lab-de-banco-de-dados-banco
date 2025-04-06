package com.banco.agenciaBancaria.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ClienteConta {
	private String cliente_cpf;
	private String conta_codigo;
}
