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
<title>Login</title>
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
	<form action="login" method="get" class="mt-4 bg-dark">
		<div
			class="container-fluid d-flex flex-column justify-content-center align-items-center">
			<div class="bg-light p-4 rounded-4 w-25">
				<div class="w-100 text-center text-dark">
					<h1 class="my-3">Login</h1>
				</div>
				<div
					class="w-100 d-flex flex-column gap-2 justify-content-center align-items-center">
					<input type="text" id="cpf" name="cpf" class="form-control"
						placeholder="CPF"> <input type="password" name="senha"
						class="form-control" placeholder="Senha">
					<button type="submit" name="botao" value="Logar"
						class="btn btn-success w-100">Logar</button>
				</div>
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