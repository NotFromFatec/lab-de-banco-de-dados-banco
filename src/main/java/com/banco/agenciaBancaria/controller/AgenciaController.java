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

import com.banco.agenciaBancaria.model.Agencia;
import com.banco.agenciaBancaria.persistence.AgenciaDao;

@Controller
public class AgenciaController {
	@Autowired
	private AgenciaDao aDao;

	// Carrega a página agencia
	@RequestMapping(name = "agencia", value = "/agencia", method = RequestMethod.GET)
	public ModelAndView agenciaGet(@RequestParam Map<String, String> params, ModelMap model) {
		// Pega o botão que foi pressionado no forms
		String acao = params.get("acao");
		int codigo = 0;
		// Verifica se o codigo passado na página é nulo
		if (params.get("id") != null && !params.get("id").isEmpty())
			codigo = Integer.parseInt(params.get("id")); // Caso não seja passa para codigo
		Agencia a = new Agencia();
		// Lista de agencias para mostrar na página
		List<Agencia> agencias = new ArrayList<>();
		String erro = "";
		String mensagem;
		try {
			// Se código for dferente de 0 realiza a operação de excluir ou editar
			if (codigo != 0) {
				a.setCodigo(codigo);
				if (acao.equals("excluir")) { // Se o botão pressionado é o de excluir
					mensagem = aDao.excluir(a);
					if (mensagem.contains("Erro")) {
						agencias = null; // Se houver algum erro, mostra o erro e apaga a lista
						erro = mensagem;
					}
					else // Senão atualiza a lista
					// Atualiza a lista
					agencias = aDao.listar();
					// Deixa os inputs nulos
					a = null;
				} else if (acao.equals("editar")) { // Se o botão pressionado é o de editar
					a = aDao.buscar(a);
					// Esvazia a lista para editar uma agência
					agencias = null;
				}
			}
		} catch (SQLException | ClassNotFoundException e) {
			erro = e.getMessage();
		} finally {
			// Adiciona os atributos na página
			model.addAttribute("erro", erro);
			model.addAttribute("agencia", a);
			model.addAttribute("agencias", agencias);
		}
		return new ModelAndView("agencia");
	}

	// Método para o formulário
	@RequestMapping(name = "agencia", value = "/agencia", method = RequestMethod.POST)
	public ModelAndView agenciaPost(@RequestParam Map<String, String> params, ModelMap model) {
		int codigo = 0;
		// Verifica se o codigo passado na página é nulo
		if (params.get("codigo") != null && !params.get("codigo").isEmpty())
			codigo = Integer.parseInt(params.get("codigo")); // Caso não seja passa para codigo
		// Pega todos os parâmetros da página
		String nome = params.get("nome");
		String cep = params.get("cep");
		String cidade = params.get("cidade");
		String cmd = params.get("botao");

		Agencia a = new Agencia();
		if (!cmd.equalsIgnoreCase("Listar")) {
			a.setCodigo(codigo);
		}
		if (cmd.contentEquals("Inserir") || cmd.equalsIgnoreCase("Atualizar")) {
			a.setNome(nome);
			a.setCep(cep);
			a.setCidade(cidade);
		}

		String saida = "";
		String erro = "";
		List<Agencia> agencias = new ArrayList<Agencia>();

		try {
			if (cmd.equalsIgnoreCase("Inserir")) {
				String mensagem = aDao.inserir(a); // Mensagem que retorna na query do banco de dados
				if (mensagem.contains("Erro"))
					erro = mensagem; // Verificando se é mensagem de erro pra exibir em vermelho
				else
					saida = mensagem; // Se não é, exibe em azul
			}
			if (cmd.equalsIgnoreCase("Atualizar")) {
				String mensagem = aDao.atualizar(a);
				if (mensagem.contains("Erro"))
					erro = mensagem;
				else
					saida = mensagem;
			}
			if (cmd.equalsIgnoreCase("Excluir")) {
				String mensagem = aDao.excluir(a);
				if (mensagem.contains("Erro"))
					erro = mensagem;
				else
					saida = mensagem;
			}
			if (cmd.equalsIgnoreCase("Buscar")) {
				a = aDao.buscar(a);
			}
			if (cmd.equalsIgnoreCase("Listar")) {
				agencias = aDao.listar();
			}
		} catch (SQLException | ClassNotFoundException e) {
			erro = e.getMessage();
		} finally {
			if (!cmd.equalsIgnoreCase("Buscar")) {
				a = null;
			}
			if (!cmd.equalsIgnoreCase("Listar")) {
				agencias = null;
			}
		}
		// Adiciona os atributos na página
		model.addAttribute("erro", erro);
		model.addAttribute("saida", saida);
		model.addAttribute("agencia", a);
		model.addAttribute("agencias", agencias);

		return new ModelAndView("agencia");
	}

}
