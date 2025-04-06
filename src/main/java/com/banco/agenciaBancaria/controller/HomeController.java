package com.banco.agenciaBancaria.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpSession;
import com.banco.agenciaBancaria.model.Cliente;

@Controller
public class HomeController {

	// Exibe a página inicial com os dados do cliente armazenado na sessão
	@RequestMapping(name = "home", value = "/home", method = RequestMethod.GET)
	public ModelAndView exibirHome(HttpSession session) {
		Cliente cliente = (Cliente) session.getAttribute("cliente");
		if (cliente == null)
			return new ModelAndView("redirect:/login"); // Se cliente não estiver logado, retorna pra página de login

		return new ModelAndView("/home");
	}
}
