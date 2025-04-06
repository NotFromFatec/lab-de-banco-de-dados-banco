<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<title>Cadastro de Agências</title>
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
		<form action="agencia" method="post"
			class="bg-dark d-flex flex-column align-items-center justify-content-center mt-4">
			<fieldset class="p-3 border">
				<legend class="text-light text-center display-6 fw-bold">Cadastro
					de Agências</legend>
				<div class="mb-3">
					<label for="codigo" class="form-label text-light">Buscar
						pelo Código</label>
					<div class="d-flex gap-2">
						<input type="number" id="codigo" name="codigo"
							class="form-control" placeholder="Código"
							value="<c:out value='${agencia.codigo}' />">
						<button type="submit" name="botao" value="Buscar"
							class="btn btn-secondary w-25">Buscar</button>
					</div>
				</div>

				<div class="mb-3">
					<label for="input-nome" class="form-label text-light">Nome</label>
					<input id="input-nome" type="text" name="nome" class="form-control"
						placeholder="Nome" value="<c:out value='${agencia.nome}' />"
						onchange="checarInput(event)" onkeyup="checarInput(event)">
				</div>

				<div class="mb-3">
					<label for="input-cep" class="form-label text-light">Cep</label> <input
						id="input-cep" type="text" name="cep" class="form-control"
						placeholder="Cep" value="<c:out value='${agencia.cep}' />"
						onchange="checarInput(event)" onkeyup="checarInput(event)">
				</div>

				<div class="mb-3">
					<label for="input-cidade" class="form-label text-light">Cidade</label>
					<input id="input-cidade" type="text" name="cidade"
						class="form-control" placeholder="Cidade"
						value="<c:out value='${agencia.cidade}' />"
						onchange="checarInput(event)" onkeyup="checarInput(event)">
				</div>

				<div class="d-flex gap-2">
					<button id="botao-inserir" type="submit" name="botao"
						value="Inserir" class="btn btn-success">Inserir</button>
					<button id="botao-atualizar" type="submit" name="botao"
						value="Atualizar" class="btn btn-primary">Atualizar</button>
					<button type="submit" name="botao" value="Excluir"
						class="btn btn-danger">Excluir</button>
					<button type="submit" name="botao" value="Listar"
						class="btn btn-warning">Listar</button>
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

		<c:if test="${not empty agencias}">
			<table class="table table-dark table-striped mt-4">
				<thead>
					<tr>
						<th>Código</th>
						<th>Nome</th>
						<th>Cep</th>
						<th>Cidade</th>
						<th>Editar</th>
						<th>Excluir</th>
					</tr>
				</thead>
				<tbody>
					<c:forEach var="a" items="${agencias}">
						<tr>
							<td>${a.codigo}</td>
							<td>${a.nome}</td>
							<td>${a.cep}</td>
							<td>${a.cidade}</td>
							<td><a href="agencia?acao=editar&id=${a.codigo}"
								class="btn btn-warning btn-sm">Editar</a></td>
							<td><a href="agencia?acao=excluir&id=${a.codigo}"
								class="btn btn-danger btn-sm">Excluir</a></td>
						</tr>
					</c:forEach>
				</tbody>
			</table>
		</c:if>
	</div>
	<script>
		// Função que desabilita botões de Inserir e Atualizar se algum campo estiver vazio
		function checarInput(event) {
			if ((document.getElementById('input-nome').value).trim() == ''
					|| (document.getElementById('input-cep').value).trim() == ''
					|| (document.getElementById('input-cidade').value).trim() == '') {
				document.getElementById("botao-inserir").disabled = true;
				document.getElementById("botao-atualizar").disabled = true;
			} else {
				document.getElementById("botao-inserir").disabled = false;
				document.getElementById("botao-atualizar").disabled = false;
			}
		}
		checarInput({});
	</script>
</body>
</html>
