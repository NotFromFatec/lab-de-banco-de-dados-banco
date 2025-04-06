<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<title>Edição de Conta</title>
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<link href="resources/css/style.css" type="text/css" rel="stylesheet">
<script
	src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>
<body class="bg-dark min-vh-100 d-flex flex-column">
	<div class="container mt-3">
		<div class="d-flex align-items-center mb-4">
			<a href="/agenciaBancaria/consultarContas" class="me-2"> <img
				src="${pageContext.request.contextPath}/resources/assets/setinha.png"
				alt="Voltar" style="max-width: 40px;">
			</a>
			<h1 class="text-white mb-0">Atualizar Contas</h1>
		</div>

		<div class="text-light text-center">
			<form action="contaAtualizar" method="post">
				<div class="mb-3 mx-auto" style="max-width: 300px;">
					<label class="form-label">Saldo</label> <input type="number"
						name="saldo" class="form-control" step="0.01"
						value="<c:out value='${conta.saldo}' />">
				</div>

				<c:choose>
					<c:when test="${conta.tipo_conta == 'C'}">
						<div class="mb-3 mx-auto" style="max-width: 300px;">
							<label class="form-label">Limite de Crédito</label> <input
								type="number" name="limite_credito" class="form-control"
								step="0.01"
								value="<c:out value='${conta_corrente.limite_credito}' />">
						</div>
					</c:when>
					<c:when test="${conta.tipo_conta == 'P'}">
						<div class="mb-3 mx-auto" style="max-width: 300px;">
							<label class="form-label">Percentual de Rendimento</label> <input
								type="number" name="percentual_rendimento" class="form-control"
								step="0.01"
								value="<c:out value='${conta_poupanca.percentual_rendimento}' />">
						</div>
						<div class="mb-3 mx-auto" style="max-width: 300px;">
							<label class="form-label">Dia do Aniversário</label> <input
								type="number" name="dia_aniversario" class="form-control"
								value="<c:out value='${conta_poupanca.dia_aniversario}' />">
						</div>
					</c:when>
				</c:choose>

				<div class="d-grid mt-4 mx-auto" style="max-width: 200px;">
					<input type="submit" name="botao" value="Atualizar"
						class="btn btn-success">
				</div>
			</form>
			<c:if test="${not empty saida}">
				<div class="mt-3 alert alert-primary w-100 mx-auto">
					<c:out value="${saida}" />
				</div>
			</c:if>

			<c:if test="${not empty erro}">
				<div class="mt-3 alert alert-danger w-100 mx-auto">
					<c:out value="${erro}" />
				</div>
			</c:if>
		</div>
	</div>
</body>
</html>
