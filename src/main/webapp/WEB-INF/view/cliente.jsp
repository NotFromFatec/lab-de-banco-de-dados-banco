<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<title>Cadastro de Clientes</title>
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
		<a href="/agenciaBancaria"
			class="text-decoration-none text-light fw-bold"> <img
			style="max-width: 50px;"
			src="${pageContext.request.contextPath}/resources/assets/setinha.png"
			alt="seta">
		</a>
	</div>
	<div class="container m-auto">
		<form action="cliente" method="post"
			class="bg-dark d-flex flex-column align-items-center justify-content-center">
			<fieldset class="p-3 border">
				<legend class="text-light text-center display-6 fw-bold">Cadastro
					de Clientes</legend>
				<div class="mb-3">
					<label for="cpf" class="form-label text-light">CPF</label>
					<div class="d-flex gap-2">
						<input type="text" id="cpf" name="cpf" class="w-75 form-control"
							placeholder="Digite o CPF"
							value="<c:out value='${cliente.cpf}' />"
							onchange="checarInput(event)" onkeyup="checarInput(event)">
						<button type="submit" name="botao" value="Buscar"
							class="btn btn-secondary w-25">Buscar</button>
					</div>
				</div>
				<div class="mb-3">
					<label for="nome" class="form-label text-light">Nome</label> <input
						id="input-nome" type="text" id="nome" name="nome"
						class="form-control w-100" placeholder="Digite o Nome"
						value="<c:out value='${cliente.nome}' />"
						onchange="checarInput(event)" onkeyup="checarInput(event)">
				</div>
				<div class="mb-3">
					<label for="senha" class="form-label text-light">Senha</label> <input
						id="input-senha" type="password" id="senha" name="senha"
						class="form-control w-100" placeholder="Digite a Senha"
						onchange="checarInput(event)" onkeyup="checarInput(event)">
				</div>
				<div class="d-flex gap-2">
					<button id="botao-inserir" type="submit" name="botao"
						value="Inserir" class="btn btn-success w-50">Inserir</button>
					<button type="submit" name="botao" value="Excluir"
						class="btn btn-danger w-50">Excluir</button>
					<button type="submit" name="botao" value="Listar"
						class="btn btn-warning w-50">Listar</button>
				</div>
			</fieldset>
		</form>
		<c:if test="${not empty saida}">
			<div class="mt-3 alert alert-primary w-100 mx-auto">
				<c:out value="${saida}" />
			</div>
		</c:if>

		<c:if test="${not empty erro}">
			<div class="mt-3 alert alert-danger w-auto mx-auto">
				<c:out value="${erro}" />
			</div>
		</c:if>
		<c:if test="${not empty clientes}">
			<table class="table table-dark table-striped mt-4">
				<thead>
					<tr>
						<th>CPF</th>
						<th>Nome</th>
						<th>Data Primeira Conta</th>
						<th>Excluir</th>
					</tr>
				</thead>
				<tbody>
					<c:forEach var="c" items="${clientes}">
						<tr>
							<td>${c.cpf}</td>
							<td>${c.nome}</td>
							<td>${c.data_primeira_conta}</td>
							<td><a href="cliente?acao=excluir&id=${c.cpf}"
								class="btn btn-danger btn-sm">Excluir</a></td>
						</tr>
					</c:forEach>
				</tbody>
			</table>
		</c:if>
	</div>
	<script>
		// Função que confere se todos os inputs foram inseridos, se não foram
		// desabilita o botão de inserir, impossibilitando o cadastro de campos vazios
		function checarInput(event) {
			if ((document.getElementById('cpf').value).trim() == ''
					|| (document.getElementById('input-nome').value).trim() == ''
					|| (document.getElementById('input-senha').value).trim() == '') {
				document.getElementById("botao-inserir").disabled = true;
			} else {
				document.getElementById("botao-inserir").disabled = false;
			}
		}
		checarInput({});
	</script>
</body>
</html>
