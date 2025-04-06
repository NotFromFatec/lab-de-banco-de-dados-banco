<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<title>Conta Conjunta</title>
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<link href="resources/css/style.css" type="text/css" rel="stylesheet">
<script
	src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>
<body class="bg-dark">
	<div class="d-flex justify-content-start m-3">
		<a href="/agenciaBancaria/consultarContas"
			class="text-decoration-none text-light fw-bold"> <img
			style="max-width: 50px;"
			src="${pageContext.request.contextPath}/resources/assets/setinha.png"
			alt="seta">
		</a>
	</div>
	<div class="container m-auto my-4">
		<form action="${pageContext.request.contextPath}/contaConjunta"
			method="get"
			class="bg-dark d-flex flex-column align-items-center justify-content-center">
			<fieldset class="p-3 border">
				<legend class="text-light text-center display-6 fw-bold">
					Adicionar alguém à conta conjunta </legend>
				<div class="mb-3">
					<label for="cpf" class="form-label text-light">CPF do
						Titular</label> <input type="text" id="cpf" name="cpf"
						class="form-control" placeholder="CPF do Titular"
						value="<c:out value='${cliente.cpf}' />">
				</div>
				<div class="mb-3">
					<label for="companheiro_cpf" class="form-label text-light">CPF
						do Companheiro</label> <input type="text" id="companheiro_cpf"
						name="companheiro_cpf" class="form-control"
						placeholder="CPF do Companheiro">
				</div>
				<div class="mb-3">
					<label for="conta_codigo" class="form-label text-light">Código
						da Conta</label> <input type="text" id="conta_codigo" name="conta_codigo"
						class="form-control" placeholder="Código da Conta"
						value="<c:out value='${conta.codigo}' />">
				</div>
				<div class="mb-3">
					<label for="senha" class="form-label text-light">Senha do
						Titular</label> <input type="password" id="senha" name="senha"
						class="form-control" placeholder="Senha do Titular">
				</div>
				<div class="d-flex gap-2">
					<input type="submit" name="botao" value="Adicionar"
						class="btn btn-success w-50">
				</div>
			</fieldset>
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
</body>
</html>
