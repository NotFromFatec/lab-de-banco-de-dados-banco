<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<script
	src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<link href="style.css" type="text/css" rel="stylesheet">
<meta charset="UTF-8">
<title>Alterar senha</title>
</head>
<body class="bg-dark">
	<div class="d-flex justify-content-start m-3">
		<a href="/agenciaBancaria/home"
			class="text-decoration-none text-light fw-bold"> <img
			style="max-width: 50px;"
			src="${pageContext.request.contextPath}/resources/assets/setinha.png"
			alt="seta">
		</a>
	</div>
	<form action="alterarSenha" method="get" class="mt-4 bg-dark">
		<div
			class="container-fluid d-flex flex-column justify-content-center align-items-center">
			<div class="border p-4">
				<div class="w-150 text-center">
					<h1 class="text-light text-center my-3">Alterar Senha</h1>
				</div>
				<div class="w-150 text-center my-2"></div>
				<input type="password" name="senha_antiga" class="form-control"
					placeholder="Senha atual" />">
				<div class="w-150 text-center my-2">
					<input type="password" name="senha_nova" class="form-control"
						placeholder="Nova Senha" />">
				</div>
				<div class="w-150 text-center my-2">
					<input type="submit" name="botao" value="Alterar Senha"
						class="btn btn-success w-100">
				</div>
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
	</form>
</body>
</html>