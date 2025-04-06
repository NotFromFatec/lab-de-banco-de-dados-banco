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
import com.banco.agenciaBancaria.model.ContaCorrente;
import com.banco.agenciaBancaria.model.ContaPoupanca;
import com.banco.agenciaBancaria.persistence.ContaDao;

import jakarta.servlet.http.HttpSession;

@Controller
public class ContaAtualizarController {
	@Autowired
	private ContaDao cDao;

	// Carrega a página de atualizar conta
	@RequestMapping(name = "contaAtualizar", value = "/contaAtualizar", method = RequestMethod.GET)
	public ModelAndView contaAtualizarGet(@RequestParam Map<String, String> params, ModelMap model,
			HttpSession session) {
		Cliente cliente = (Cliente) session.getAttribute("cliente");
		Conta conta = (Conta) session.getAttribute("conta"); // Pega os objetos de cliente e conta
		if (cliente == null)
			return new ModelAndView("redirect:/login");
		if (conta == null)
			return new ModelAndView("redirect:/consultarConta"); // Verifica se algum dos dois é nulo para redirecionar
																	// até suas páginas
		// Adiciona o atributo de conta para usar na página
		String erro = "";
		
		ContaCorrente conta_corrente = new ContaCorrente();
		ContaPoupanca conta_poupanca = new ContaPoupanca();
		try {
			cDao.consultarDetalhes(conta, conta_corrente, conta_poupanca, null); // Busca dos detalhes das contas
		} catch (SQLException | ClassNotFoundException e) {
			erro = e.getMessage();
		} finally {
			model.addAttribute("conta_corrente", conta_corrente);
			model.addAttribute("conta_poupanca", conta_poupanca); // Coloca na página
			model.addAttribute("erro", erro);
		}
		model.addAttribute("conta", conta);

		return new ModelAndView("contaAtualizar");
	}

	@RequestMapping(name = "contaAtualizar", value = "/contaAtualizar", method = RequestMethod.POST)
	public ModelAndView contaAtualizarPost(@RequestParam Map<String, String> params, ModelMap model,
			HttpSession session) {
		Conta conta = (Conta) session.getAttribute("conta");
		ContaCorrente conta_corrente = new ContaCorrente();
		ContaPoupanca conta_poupanca = new ContaPoupanca();
		String saida = null;
		String erro = null;

		// Verifica se todos os parâmetros não são nulos
		Double saldo = 0.0;
		if (params.get("saldo") != null && !params.get("saldo").isEmpty()) {
			saldo = Double.parseDouble(params.get("saldo"));
		}

		Double limite_credito = 0.0;
		if (params.get("limite_credito") != null && !params.get("limite_credito").isEmpty()) {
			limite_credito = Double.parseDouble(params.get("limite_credito"));
		}

		Double percentual_rendimento = 0.0;
		if (params.get("percentual_rendimento") != null && !params.get("percentual_rendimento").isEmpty()) {
			percentual_rendimento = Double.parseDouble(params.get("percentual_rendimento"));
		}

		int dia_aniversario = 0;
		if (params.get("dia_aniversario") != null && !params.get("dia_aniversario").isEmpty()) {
			dia_aniversario = Integer.parseInt(params.get("dia_aniversario"));
		}
		if (dia_aniversario > 31 || dia_aniversario <= 0 && conta.getTipo_conta().equals("P")) { // Verifica se é um dia válido
			erro = "Dia só pode ser entre dia 1 e 31";
			model.addAttribute("erro", erro);
			return new ModelAndView("contaAtualizar");
		}

		conta.setSaldo(saldo);

		String cmd = params.get("botao");

		// Se o botão clicado for o de atualizar
		if (cmd.equalsIgnoreCase("Atualizar")) {
			if (conta.getTipo_conta().equals("C")) { // Se o tipo da conta for Corrente
				conta_corrente.setLimite_credito(limite_credito); // Armazena o limite de crédito na conta corrente
			} else if (conta.getTipo_conta().equals("P")) { // Se for poupança
				conta_poupanca.setPercentual_rendimento(percentual_rendimento);
				conta_poupanca.setDia_aniversario(dia_aniversario); // Armazena o dia de aniversário e o percentual de
																	// rendimento ao objeto de conta poupança
			}
			try {
				// Atualiza a conta de acordo com seu tipo e recebe a mensagem do procedimento
				String mensagem = cDao.atualizar(conta, conta_corrente, conta_poupanca);
				if (mensagem.contains("Erro"))
					erro = mensagem; // Se a mensagem contém erro armazena em erro
				else
					saida = mensagem; // Senão armazena em sáida pra mostrar em azul
			} catch (SQLException | ClassNotFoundException e) {
				e.getMessage();
			} finally {
				// Passa as mensagens pra página
				model.addAttribute("erro", erro);
				model.addAttribute("saida", saida);
			}
		}
		return new ModelAndView("contaAtualizar");
	}
}