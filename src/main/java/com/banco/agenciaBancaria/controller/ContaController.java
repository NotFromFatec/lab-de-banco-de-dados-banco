package com.banco.agenciaBancaria.controller;

import java.sql.SQLException;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.banco.agenciaBancaria.model.Cliente;
import com.banco.agenciaBancaria.model.Conta;
import com.banco.agenciaBancaria.persistence.ContaDao;

import jakarta.servlet.http.HttpSession;

@Controller
public class ContaController {
	@Autowired
	private ContaDao cDao;

	// Carrega a página de cadastro de conta
	@RequestMapping(name = "conta", value = "/conta", method = RequestMethod.GET)
	public ModelAndView contaGet(@RequestParam Map<String, String> params, ModelMap model, HttpSession session) {
		Cliente cliente = (Cliente) session.getAttribute("cliente"); // Busca o objeto de cliente que está logado
		if (cliente == null)
			return new ModelAndView("redirect:/login"); // Se cliente não realizou login retorna para a tela de login

		return new ModelAndView("conta");
	}

	// Método para a criação de conta no formulário
	@RequestMapping(name = "conta", value = "/conta", method = RequestMethod.POST)
	public ModelAndView contaPost(@RequestParam Map<String, String> params, ModelMap model, HttpSession session) {
		Cliente cliente = (Cliente) session.getAttribute("cliente"); // Recupera o objeto de cliente

		int aCodigo = 0;
		if (params.get("a_codigo") != null && !params.get("a_codigo").isEmpty()) {
			aCodigo = Integer.parseInt(params.get("a_codigo")); // Verifica se o parâmetro de código não está vazio e
																// passa para a variável
		}

		// Pega todos os parâmetros passados na página
		String cpf = params.get("c_cpf");
		String opcao = params.get("tipo_conta");
		String saida = null;
		String erro = null;

		Conta c = new Conta();
		c.setAgencia_codigo(aCodigo); // Setta no objeto agencia o código passado na página

		if ("poupanca".equalsIgnoreCase(opcao)) { // Se cliente selecionar a opção de conta poupança
			c.setTipo_conta("P"); // Setta o valor como P para ser armazenado no banco de dados na tabela conta
									// poupça
		} else if ("corrente".equalsIgnoreCase(opcao)) { // Se cliente selecionar a opção de conta corrente
			c.setTipo_conta("C"); // Setta o valor como C para ser armazenado no banco de dados na tabela conta
									// corrente
		}

		try {
			// Insere a conta no banco de dados e retorna uma mensagem
			String mensagem = cDao.inserir(c, cpf);
			if (mensagem.contains("Erro")) {
				erro = mensagem; // Se a mensagem for de erro
			} else {
				saida = mensagem; // Mensagem de sucesso
			}
		} catch (SQLException | ClassNotFoundException e) {
			erro = e.getMessage(); // Armazena em erro para registrar o erro corretamente
		} finally {
			// Adiciona os atributos dos objetos para a página
			model.addAttribute("cliente", cliente);
			model.addAttribute("saida", saida);
			model.addAttribute("erro", erro);
		}
		return new ModelAndView("conta");
	}
}