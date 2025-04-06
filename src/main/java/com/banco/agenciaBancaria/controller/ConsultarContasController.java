package com.banco.agenciaBancaria.controller;

import java.sql.SQLException;
import java.util.List;
import java.util.ArrayList;
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
public class ConsultarContasController {

	@Autowired
	private ContaDao cDao;

	@RequestMapping(name = "consultarContas", value = "/consultarContas", method = RequestMethod.GET)
	public ModelAndView consultarContasGet(@RequestParam Map<String, String> params, ModelMap model,
			HttpSession session) {
		Cliente cliente = (Cliente) session.getAttribute("cliente");
		if (cliente == null) {
			return new ModelAndView("redirect:/login"); // Redireciona para login se cliente não existir
		}
		String acao = params.get("acao");
		String erro = "";
		String saida = "";
		List<Conta> contas = new ArrayList<>();
		Conta conta = new Conta();
		String codigo = params.get("id");
		try {
			// Passa apenas uma conta para a lista de contas
			contas = cDao.listar(cliente.getCpf());
		} catch (SQLException | ClassNotFoundException e) {
			erro = e.getMessage(); // Alterado para registrar o erro corretamente
		} finally {
			model.addAttribute("contas", contas);
		}

		try {
			if (codigo != null) {
				conta.setCodigo(codigo);
				// Se o botão clicado for o de excluir
				if (acao.equals("excluir")) {
					String mensagem = cDao.excluir(conta);
					if (mensagem.contains("Erro"))
						erro = mensagem; // Se retornar mensagem de erro atribui a erro
					else
						saida = mensagem; // Senão mensagem em azul
					contas = null;
					conta = null;
				} else if (acao.equals("editar")) { // Se o botão clicado for o de editar
					conta = cDao.buscar(conta); // Busca a conta de acordo com o código para preencher o objeto conta
					session.setAttribute("conta", conta); // Passa ele pra session pra guardar suas informações nas
															// páginas
					return new ModelAndView("redirect:/contaAtualizar"); // Redireciona para a página de edição de conta
				} else if (acao.equals("detalhes")) { // Se o botão clicado for o de exibir detalhes da conta
					conta = cDao.buscar(conta);
					session.setAttribute("conta", conta);
					return new ModelAndView("redirect:/detalhesConta"); // Redireiona para a página de conferir detalhes
				} else if (acao.equals("adicionar")) { // Se o botão clicado for o de adicionar compnaheiro a conta
					conta = cDao.buscar(conta);
					session.setAttribute("conta", conta);
					return new ModelAndView("redirect:/contaConjunta"); // Redireiona para a página de adicionar
																		// compnaheiro
				}
			}
		} catch (SQLException | ClassNotFoundException e) {
			erro = e.getMessage();
		} finally {
			model.addAttribute("contas", contas);
			model.addAttribute("erro", erro);
			model.addAttribute("saida", saida);
		}

		return new ModelAndView("consultarContas");
	}

	@RequestMapping(value = "/consultarContas", method = RequestMethod.POST)
	public ModelAndView consultarContasPost(@RequestParam Map<String, String> params, ModelMap model,
			HttpSession session) {
		Cliente cliente = (Cliente) session.getAttribute("cliente");
		if (cliente == null) {
			return new ModelAndView("redirect:/login");
		}
		List<Conta> contas = new ArrayList<>();
		String cCodigo = params.get("codigo");
		String cmd = params.get("botao");
		String erro = "";

		// Clicou no botão de buscar uma conta
		if ("Buscar".equalsIgnoreCase(cmd)) {
			// Se o campo código estiver preenchido, busca a conta específica que o usuário
			// deseja
			if (cCodigo != null && !cCodigo.trim().isEmpty()) {
				try {
					Conta conta = new Conta();
					conta.setCodigo(cCodigo);
					conta = cDao.buscar(conta);
					// Verifica se a conta buscada é nula
					if (conta != null) {
						// Cria uma lista com a conta encontrada para mostrar na tela
						contas.add(conta);
						model.addAttribute("contas", contas);
						// Se for exibe a mensagem de erro
					} else {
						erro = "Conta não econtrada";
					}
				} catch (SQLException | ClassNotFoundException e) {
					erro = e.getMessage();
				}
			} else {
				// Se o campo código estiver vazio, e o usuário buscar, irá mostrar todas as
				// contas
				try {
					contas = cDao.listar(cliente.getCpf());
				} catch (SQLException | ClassNotFoundException e) {
					erro = e.getMessage();
				}
			}
		}
		model.addAttribute("contas", contas);
		model.addAttribute("erro", erro);
		return new ModelAndView("consultarContas");
	}

}
