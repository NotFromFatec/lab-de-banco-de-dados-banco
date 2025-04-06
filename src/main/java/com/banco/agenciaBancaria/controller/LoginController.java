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
import com.banco.agenciaBancaria.persistence.ClienteDao;

import jakarta.servlet.http.HttpSession;

@Controller
public class LoginController {

	@Autowired
	private ClienteDao cDao;

	// Método GET para exibir a página de login
	@RequestMapping(value = "/login", method = RequestMethod.GET)
	public ModelAndView mostrarLogin(@RequestParam Map<String, String> params, HttpSession session, ModelMap model) {
		// Pega os parâmetros da página
		String cpf = params.get("cpf");
		String senha = params.get("senha");
		String cmd = params.get("botao");

		// Se o botão "Logar" não foi pressionado, não faz nada
		if (cmd == null || !cmd.equals("Logar")) {
			return new ModelAndView("login");
		}
		// Criando objeto cliente
		Cliente c = new Cliente();
		c.setCpf(cpf);
		c.setSenha(senha);

		String erro = "";
		if (cmd.equals("Logar")) {
			try {
				int valido = cDao.validarLogin(c); // Se retornar 1 por que login está correto
				if (valido == 1) { // Login bem sucedido
					session.setAttribute("cliente", c); // Guarda o cliente logado
					return new ModelAndView("redirect:/home"); // Retorna para a home se login foi bem sucedido
				} else
					erro = "Cpf ou senha inválidos"; // Define a mensagem de erro de login na tela
			} catch (SQLException | ClassNotFoundException e) {
				erro = e.getMessage();
			}
		}
		// Mapeia a página com as variáveis e retorna
		model.addAttribute("erro", erro);
		return new ModelAndView("login", model);
	}
}
