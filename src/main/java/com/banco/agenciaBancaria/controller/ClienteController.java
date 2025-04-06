package com.banco.agenciaBancaria.controller;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
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

@Controller
public class ClienteController {
	@Autowired
	private ClienteDao cDao;

	// Carrega a página para cadastro de cliente
	@RequestMapping(name = "cliente", value = "/cliente", method = RequestMethod.GET)
	public ModelAndView pessoaGet(@RequestParam Map<String, String> params, ModelMap model) {
		// Pega o botão que foi pressionado no forms
		String acao = params.get("acao");
		String cpf = params.get("id");
		Cliente c = new Cliente();
		List<Cliente> clientes = new ArrayList<>();
		String erro = "";
		try {
			// Se cpf passado na página for diferente de null passa pro objeto cliente
			if (cpf != null && !cpf.isBlank()) {
				c.setCpf(cpf);
				// Se o botão clicado foi o de excluir
				if (acao.equals("excluir")) {
					// Exclui cliente no banco
					erro = cDao.excluir(c);
					if (erro.contains("Erro")) clientes = null; // Verifica se retornou algum erro ao excluir
																// Se retorniu, apaga a lista para exibir o erro
					else { // Senão, atualiza a lista
						clientes = cDao.listar();
						c = null;
					}
				}
			}
		} catch (SQLException | ClassNotFoundException e) {
			e.getMessage();
		} finally {
			// Passa os atributos pra página
			model.addAttribute("erro", erro);
			model.addAttribute("cliente", c);
			model.addAttribute("clientes", clientes);
		}
		return new ModelAndView("cliente");
	}

	// Método para pegar do formulário
	@RequestMapping(name = "cliente", value = "/cliente", method = RequestMethod.POST)
	public ModelAndView pessoaPost(@RequestParam Map<String, String> params, ModelMap model) {
		// Pega os valores dos inputs da página
		String cpf = params.get("cpf");
		String nome = params.get("nome");
		String senha = params.get("senha");
		String cmd = params.get("botao");

		Cliente c = new Cliente();
		if (!cmd.equalsIgnoreCase("Listar")) {
			c.setCpf(cpf);
		}
		if (cmd.contentEquals("Inserir")) {
			c.setNome(nome);
			c.setSenha(senha);
		}

		String saida = "";
		String erro = "";
		List<Cliente> clientes = new ArrayList<Cliente>();

		try {
			if (cmd.equalsIgnoreCase("Inserir")) {
				String mensagem = cDao.inserir(c); // Mensagem que retorna na query do banco de dados
				if (mensagem.contains("Erro"))
					erro = mensagem; // Verificando se é mensagem de erro pra exibir em vermelho
				else
					saida = mensagem; // Se não é, exibe em azul
			}
			if (cmd.equalsIgnoreCase("Excluir")) {
				String mensagem = cDao.excluir(c);
				if (mensagem.contains("Erro"))
					erro = mensagem;
				else
					saida = mensagem;
			}
			if (cmd.equalsIgnoreCase("Buscar")) {
				c = cDao.buscar(c);
			}
			if (cmd.equalsIgnoreCase("Listar")) {
				clientes = cDao.listar();
			}
		} catch (SQLException | ClassNotFoundException e) {
			erro = e.getMessage();
		} finally {
			if (!cmd.equalsIgnoreCase("Buscar")) {
				c = null;
			}
			if (!cmd.equalsIgnoreCase("Listar")) {
				clientes = null;
			}
		}
		// Passa os atributos pra página
		model.addAttribute("erro", erro);
		model.addAttribute("saida", saida);
		model.addAttribute("cliente", c);
		model.addAttribute("clientes", clientes);

		return new ModelAndView("cliente");
	}
}