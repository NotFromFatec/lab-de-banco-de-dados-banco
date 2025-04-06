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

import jakarta.servlet.http.HttpSession;
import com.banco.agenciaBancaria.model.Cliente;
import com.banco.agenciaBancaria.persistence.ClienteDao;

@Controller
public class SenhaController {
	@Autowired
	private ClienteDao cDao;

	// Método GET para ser realizado a troca se senha do usuário já logado
	@RequestMapping(name = "alterarSenha", value = "/alterarSenha", method = RequestMethod.GET)
	public ModelAndView senhaGet(HttpSession session, @RequestParam Map<String, String> params, ModelMap model) {
		Cliente cliente = (Cliente) session.getAttribute("cliente"); // Recupera cliente da session
		if (cliente == null) {
			// Redirecione para o login se cliente não está logado
			return new ModelAndView("login", model);
		}
		// Pegando os parâmetros da página
		String senhaAtual = params.get("senha_antiga");
		String senhaNova = params.get("senha_nova");
		// Se os dois campos não estiverem preenchidos só retorna
		if (senhaAtual == null || senhaNova == null) {
			return new ModelAndView("alterarSenha");
		}
		// Definindo para objeto cliente a senha que ele inseriu no campo para ser
		// comparada com a verdadeira no banco de dados
		cliente.setSenha(senhaAtual);

		String erro = null;
		String saida = null;

		try {
			String mensagem = cDao.trocarSenha(cliente, senhaNova);
			if (mensagem.contains("Erro"))
				erro = mensagem; // Se retornar mensagem de erro passa pra erro
			else
				saida = mensagem; // Senão exbie em azul
		} catch (SQLException | ClassNotFoundException e) {
			erro = e.getMessage();
		} finally {
			model.addAttribute("erro", erro);
			model.addAttribute("saida", saida);
		}

		return new ModelAndView("alterarSenha");
	}
}
