<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<title>Detalhes de Conta</title>
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<script
	src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>
<body class="bg-dark text-light">
	
	<div class="d-flex flex-column align-items-center">
		<div class="w-25 my-3">
			<a href="/agenciaBancaria/consultarContas"
				class="text-decoration-none text-light fw-bold"> 
				<img
				 style="max-width: 50px;"
				src="${pageContext.request.contextPath}/resources/assets/setinha.png"
				alt="seta">
			</a>
		</div>
		<div class="bg-light text-dark p-4 rounded-4 shadow w-25">
			<h2 class="text-center mb-4">Detalhes da Conta</h2>
			<ul class="list-group list-group-flush">
				<li class="list-group-item">Saldo da conta: <strong>R$
						${conta.saldo}</strong></li>
				<li class="list-group-item">Código da agência: <strong>${agencia.codigo}</strong></li>
				<li class="list-group-item">Nome da agência: <strong>${agencia.nome}</strong></li>
				<li class="list-group-item">CEP da agência: <strong>${agencia.cep}</strong></li>
				<li class="list-group-item">Cidade da agência: <strong>${agencia.cidade}</strong></li>
				<li class="list-group-item">Data de abertura: <strong>${conta.data_abertura}</strong></li>
				<li class="list-group-item">CPF do titular: <strong>${cliente.cpf}</strong></li>
				<c:choose>
					<c:when test="${conta.tipo_conta == 'C'}">
						<li class="list-group-item">Tipo da conta: <strong>Corrente</strong></li>
						<li class="list-group-item">Limite de Crédito: <strong>R$
								${conta_corrente.limite_credito}</strong></li>
					</c:when>
					<c:when test="${conta.tipo_conta == 'P'}">
						<li class="list-group-item">Tipo da conta: <strong>Poupança</strong></li>
						<li class="list-group-item">Percentual de rendimento: <strong>${conta_poupanca.percentual_rendimento}%</strong></li>
						<li class="list-group-item">Dia de Aniversário: <strong>${conta_poupanca.dia_aniversario}</strong></li>
					</c:when>
				</c:choose>
			</ul>
		</div>
	</div>
</body>
</html>
