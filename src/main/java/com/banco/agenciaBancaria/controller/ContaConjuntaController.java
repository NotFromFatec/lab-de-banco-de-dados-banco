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
public class ContaConjuntaController {
	@Autowired
	private ContaDao cDao;

	// Carrega a página de conta conjunta
	@RequestMapping(name = "contaConjunta", value = "/contaConjunta", method = RequestMethod.GET)
	public ModelAndView pessoaGet(@RequestParam Map<String, String> params, ModelMap model, HttpSession session) {
		Cliente cliente = (Cliente) session.getAttribute("cliente");
		Conta conta = (Conta) session.getAttribute("conta"); // Armazena os objetos de cliente e conta que vem da
																// session
		if (cliente == null)
			return new ModelAndView("redirect:/login");
		if (conta == null)
			return new ModelAndView("redirect:/consultarContas"); // Verifica se algum é nulo, se for redireciona para
																	// suas páginas
		// Passando todos os parâmetros da página para variáveis
		String companheiro_cpf = params.get("companheiro_cpf");
		String acao = params.get("botao");
		String cpf = params.get("cpf");
		String conta_codigo = params.get("conta_codigo");
		String senha = params.get("senha");
		// Cria novo cliente e conta para os dados colocados na página não se alterem
		// como cpf do cliente e código da conta que já são colocados automaticamente
		Cliente c = new Cliente();
		Conta con = new Conta();
		// Setta seus dados para os objetos novos
		c.setCpf(cpf);
		c.setSenha(senha);
		con.setCodigo(conta_codigo);
		String erro = "";
		String saida = "";
		try {
			// Verifica se foi clicado no botão de adicionar
			if ("Adicionar".equals(acao)) {
				// Passa os objetos para ser adicionado companheiro a conta conjunta no banco de
				// dados, retorna a mensagem para a página
				String mensagem = cDao.contaConjunta(con, c, companheiro_cpf);
				if (mensagem.contains("Erro"))
					erro = mensagem; // Se a mensagem contém erro armazena em erro
				else
					saida = mensagem; // Senão armazena em saída
			}
		} catch (SQLException | ClassNotFoundException e) {
			erro = e.getMessage();
		} finally {
			// Passa a mesagem para a página
			model.addAttribute("erro", erro);
			model.addAttribute("saida", saida);
		}
		// Passa os atributos de cliente logado e conta selecionada para a página
		model.addAttribute("cliente", cliente);
		model.addAttribute("conta", conta);
		return new ModelAndView("contaConjunta");
	}
}