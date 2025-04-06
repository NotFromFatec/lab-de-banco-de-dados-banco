<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<title>Consulta de Contas</title>
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
		<a href="/agenciaBancaria/home"
			class="text-decoration-none text-light fw-bold"> <img
			style="max-width: 50px;"
			src="${pageContext.request.contextPath}/resources/assets/setinha.png"
			alt="seta">
		</a>
	</div>
	<div class="container mt-4">
		<h1 class="text-white">Consulta de Contas</h1>
		<form action="consultarContas" method="post"
			class="bg-dark d-flex justify-content-start align-items-center gap-2 w-50 p-3 rounded">
			<label class="text-light fw-bold mb-0">Buscar pelo Código:</label> <input
				type="text" id="codigo" name="codigo" class="form-control w-50"
				placeholder="Código">
			<button type="submit" name="botao" value="Buscar"
				class="btn btn-secondary">Buscar</button>
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
		<c:if test="${not empty contas}">
			<table class="table table-dark table-striped mt-4">
				<thead>
					<tr>
						<th>Código</th>
						<th>Código Agência</th>
						<th>Data Abertura</th>
						<th>Saldo</th>
						<th>Tipo da Conta</th>
						<th>Editar</th>
						<th>Excluir</th>
						<th>Detalhes</th>
						<th>Adicionar Companheiro</th>
					</tr>
				</thead>
				<tbody>
					<c:forEach var="c" items="${contas}">
						<tr>
							<td>${c.codigo}</td>
							<td>${c.agencia_codigo}</td>
							<td>${c.data_abertura}</td>
							<td>${c.saldo}</td>
							<td><c:choose>
									<c:when test="${c.tipo_conta == 'C'}">Corrente</c:when>
									<c:when test="${c.tipo_conta == 'P'}">Poupança</c:when>
								</c:choose></td>
							<td><a href="consultarContas?acao=editar&id=${c.codigo}"
								class="btn btn-warning btn-sm">Editar</a></td>
							<td><a href="consultarContas?acao=excluir&id=${c.codigo}"
								class="btn btn-danger btn-sm">Excluir</a></td>
							<td><a href="consultarContas?acao=detalhes&id=${c.codigo}"
								class="btn btn-info btn-sm">Detalhes</a></td>
							<td><a href="consultarContas?acao=adicionar&id=${c.codigo}"
								class="btn btn-primary btn-sm">Adicionar</a></td>
						</tr>
					</c:forEach>
				</tbody>
			</table>
		</c:if>
	</div>
</body>
</html>