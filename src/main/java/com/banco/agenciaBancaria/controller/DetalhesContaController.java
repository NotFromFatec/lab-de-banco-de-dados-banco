package com.banco.agenciaBancaria.controller;

import java.sql.SQLException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import com.banco.agenciaBancaria.model.Agencia;
import com.banco.agenciaBancaria.model.Cliente;
import com.banco.agenciaBancaria.model.Conta;
import com.banco.agenciaBancaria.model.ContaCorrente;
import com.banco.agenciaBancaria.model.ContaPoupanca;
import com.banco.agenciaBancaria.persistence.ContaDao;

import jakarta.servlet.http.HttpSession;

@Controller
public class DetalhesContaController {
	@Autowired
	private ContaDao cDao;

	// Carrega a página com os detalhes da conta
	@RequestMapping(name = "detalhesConta", value = "/detalhesConta", method = RequestMethod.GET)
	public ModelAndView detalhesContaGet(ModelMap model, HttpSession session) {
		Cliente cliente = (Cliente) session.getAttribute("cliente");
		Conta conta = (Conta) session.getAttribute("conta"); // Recupera cliente e conta da session
		if (cliente == null || cliente.getCpf() == null)
			return new ModelAndView("redirect:/login");
		if (conta == null || conta.getCodigo() == null) {
			return new ModelAndView("redirect:/consultarContas"); // Se algum dos dois for nulo, redireciona para página
																	// desse objeto
		}

		Agencia a = new Agencia();
		ContaPoupanca cp = new ContaPoupanca();
		ContaCorrente cc = new ContaCorrente();
		String erro = "";
		try {
			// Se ao consultar detalhes não achar a conta mostra erro
			erro = cDao.consultarDetalhes(conta, cc, cp, a);
			if (erro != null) {
				model.addAttribute("erro", erro);
			}
		} catch (SQLException | ClassNotFoundException e) {
			erro = e.getMessage(); // Se a execução da função der errado retorna a mensagem do erro de execução
		}
		// Adiciona os atributos dos objetos para mostrar na página
		model.addAttribute("conta", conta);
		model.addAttribute("cliente", cliente);
		model.addAttribute("conta_poupanca", cp);
		model.addAttribute("conta_corrente", cc);
		model.addAttribute("agencia", a);
		return new ModelAndView("/detalhesConta");
	}
}
