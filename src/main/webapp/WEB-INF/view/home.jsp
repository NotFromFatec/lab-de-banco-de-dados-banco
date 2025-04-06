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
<title>Home</title>
</head>
<body class="bg-dark">
	<div class="d-flex justify-content-start m-3">
		<a href="/agenciaBancaria"
			class="text-decoration-none text-light fw-bold"> <img
			style="max-width: 50px;"
			src="${pageContext.request.contextPath}/resources/assets/setinha.png"
			alt="seta">
		</a>
	</div>
	<div
		class="container-fluid d-flex flex-column justify-content-center align-items-center">
		<div class="border p-4">
			<div class="w-150 text-center">
				<h1 class="text-light text-center my-3">Bem vindo(a),
					${cliente.nome}!</h1>
			</div>
			<div class="w-150 text-center my-2">
				<a class="btn btn-primary w-50 p-2" href="consultarContas"
					role="button">Consultar contas</a>
			</div>
			<div class="w-150 text-center my-2">
				<a class="btn btn-primary w-50 p-2" href="conta" role="button">Criar
					uma conta</a>
			</div>
			<div class="w-150 text-center my-2">
				<a class="btn btn-primary w-50 p-2" href="alterarSenha"
					role="button">Alterar senha da conta</a>
			</div>
		</div>
	</div>
</body>
</html>