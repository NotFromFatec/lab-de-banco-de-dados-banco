<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<title>Cadastro de Contas</title>
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
	<div class="container min-vh-100 d-flex justify-content-center">
		<div class="col-12 col-md-6 col-lg-4">
			<form action="conta" method="post"
				class="bg-dark d-flex flex-column align-items-center justify-content-center">
				<fieldset class="p-3 border">
					<legend class="text-light text-center display-6 fw-bold">Criar
						Conta no Banco</legend>
					<div class="mb-3">
						<label for="input-codigo" class="form-label text-light small">Código
							Agência</label> <input id="input-codigo" type="number" name="a_codigo"
							class="form-control form-control-sm"
							placeholder="Código da Agência" onchange="checarInput(event)"
							onkeyup="checarInput(event)">
					</div>

					<div class="mb-3">
						<label for="input-cpf" class="form-label text-light small">CPF
							do Titular</label> <input id="input-cpf" type="text" name="c_cpf"
							class="form-control form-control-sm" placeholder="CPF do Titular"
							value="<c:out value='${cliente.cpf}' />"
							onchange="checarInput(event)" onkeyup="checarInput(event)">
					</div>

					<div class="mb-3">
						<label for="select-tipo-conta" class="form-label text-light small">Tipo
							de Conta</label> <select id="select-tipo-conta" name="tipo_conta"
							class="form-select form-select-sm">
							<option value="poupanca">Conta Poupança</option>
							<option value="corrente">Conta Corrente</option>
						</select>
					</div>

					<div class="d-grid">
						<button id="botao-inserir" type="submit" name="botao"
							value="Criar Conta" class="btn btn-success btn-sm">Criar
							Conta</button>
					</div>
				</fieldset>
			</form>
			<div class="mt-3">
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
	</div>

	<script>
		// Função que confere se todos os inputs foram inseridos, se não foram
		// desabilita o botão de inserir, impossibilitando o cadastro de campos vazios
		function checarInput(event) {
			if ((document.getElementById('input-cpf').value).trim() === ''
					|| (document.getElementById('input-codigo').value).trim() === '') {
				document.getElementById("botao-inserir").disabled = true;
			} else {
				document.getElementById("botao-inserir").disabled = false;
			}
		}
		checarInput({});
	</script>
</body>
</html>
