<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <link href="style.css" type="text/css" rel="stylesheet">
<meta charset="UTF-8">
<title>Index</title>
</head>
<body class="bg-dark">
	<div class="container vh-100 d-flex justify-content-center align-items-center">
		<div class="bg-light p-4 rounded-4">
			<div class="text-center">
				<h1 class="text-dark my-3">Tela Inicial</h1>
			</div>
			<div class="d-flex flex-column"> 
				<div class="my-2">
					<a class="btn btn-dark w-100 p-2" href="cliente" role="button">Cadastrar</a>
				</div>
				<div class="my-2">
					<a class="btn btn-dark w-100 p-2" href="login" role="button">Logar</a>
				</div>
				<div class="my-2">
					<a class="btn btn-dark w-100 p-2" href="agencia" role="button">Cadastrar Agência</a>
				</div>
			</div>
		</div>	
	</div>
</body>
</html>