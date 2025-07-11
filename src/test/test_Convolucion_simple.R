source("../utils/Convolucion.R")

cat("Ejecutando pruebas de la función convolucion...\n\n")

test_count <- 0
passed_count <- 0

# Test 1: Vectores simples de igual longitud
test_count <- test_count + 1
cat(sprintf("Test %d: Vectores básicos de igual longitud... ", test_count))
tryCatch({
  px <- c(0.5, 0.5)
  py <- c(0.3, 0.7)
  resultado <- convolucion(px, py)
  esperado <- c(0.15, 0.50, 0.35)
  
  if (!all(abs(resultado - esperado) < 1e-10)) {
    stop("Resultado no coincide con el esperado")
  }
  if (abs(sum(resultado) - 1) > 1e-10) {
    stop("El resultado no suma 1")
  }
  passed_count <- passed_count + 1
  cat("✓ PASÓ\n")
}, error = function(e) {
  cat(sprintf("✗ FALLÓ - %s\n", e$message))
})

# Test 2: Vectores de diferentes longitudes
test_count <- test_count + 1
cat(sprintf("Test %d: Vectores de diferentes longitudes... ", test_count))
tryCatch({
  px <- c(0.2, 0.8)
  py <- c(0.1, 0.4, 0.5)
  resultado <- convolucion(px, py)
  
  if (length(resultado) != 4) {
    stop("Longitud incorrecta")
  }
  if (abs(sum(resultado) - 1) > 1e-10) {
    stop("El resultado no suma 1")
  }
  if (abs(resultado[1] - 0.02) > 1e-10) {
    stop("P(Z=0) incorrecto")
  }
  if (abs(resultado[4] - 0.40) > 1e-10) {
    stop("P(Z=3) incorrecto")
  }
  passed_count <- passed_count + 1
  cat("✓ PASÓ\n")
}, error = function(e) {
  cat(sprintf("✗ FALLÓ - %s\n", e$message))
})

# Test 3: Variable determinística
test_count <- test_count + 1
cat(sprintf("Test %d: Variable determinística... ", test_count))
tryCatch({
  px <- c(1)
  py <- c(0, 1)
  resultado <- convolucion(px, py)
  esperado <- c(0, 1)
  
  if (!all(abs(resultado - esperado) < 1e-10)) {
    stop("Resultado incorrecto para variable determinística")
  }
  passed_count <- passed_count + 1
  cat("✓ PASÓ\n")
}, error = function(e) {
  cat(sprintf("✗ FALLÓ - %s\n", e$message))
})

# Test 4: Dados justos
test_count <- test_count + 1
cat(sprintf("Test %d: Suma de dos dados justos... ", test_count))
tryCatch({
  dado <- rep(1/6, 6)
  resultado <- convolucion(dado, dado)
  
  if (length(resultado) != 11) {
    stop("Longitud incorrecta para suma de dados")
  }
  if (abs(sum(resultado) - 1) > 1e-10) {
    stop("El resultado no suma 1")
  }
  # Verificar simetría
  if (abs(resultado[1] - resultado[11]) > 1e-10) {
    stop("Falta simetría en la distribución")
  }
  passed_count <- passed_count + 1
  cat("✓ PASÓ\n")
}, error = function(e) {
  cat(sprintf("✗ FALLÓ - %s\n", e$message))
})

# Test 5: Validación de entrada
test_count <- test_count + 1
cat(sprintf("Test %d: Validación de probabilidades negativas... ", test_count))
tryCatch({
  error_caught <- FALSE
  tryCatch({
    convolucion(c(-0.1, 1.1), c(0.5, 0.5))
  }, error = function(e) {
    error_caught <<- TRUE
  })
  
  if (!error_caught) {
    stop("No se detectó error con probabilidades negativas")
  }
  passed_count <- passed_count + 1
  cat("✓ PASÓ\n")
}, error = function(e) {
  cat(sprintf("✗ FALLÓ - %s\n", e$message))
})

# Test 6: Ejemplo práctico
test_count <- test_count + 1
cat(sprintf("Test %d: Ejemplo práctico con distribuciones asimétricas... ", test_count))
tryCatch({
  # Variable X: principalmente concentrada en 0
  px <- c(0.7, 0.2, 0.1)
  # Variable Y: más dispersa
  py <- c(0.1, 0.3, 0.4, 0.2)
  
  resultado <- convolucion(px, py)
  
  if (length(resultado) != 6) {  # 3 + 4 - 1 = 6
    stop("Longitud incorrecta")
  }
  if (abs(sum(resultado) - 1) > 1e-10) {
    stop("El resultado no suma 1")
  }
  
  # P(Z=0) = P(X=0,Y=0) = 0.7 * 0.1 = 0.07
  if (abs(resultado[1] - 0.07) > 1e-10) {
    stop("P(Z=0) incorrecto")
  }
  
  # P(Z=5) = P(X=2,Y=3) = 0.1 * 0.2 = 0.02
  if (abs(resultado[6] - 0.02) > 1e-10) {
    stop("P(Z=5) incorrecto")
  }
  passed_count <- passed_count + 1
  cat("✓ PASÓ\n")
}, error = function(e) {
  cat(sprintf("✗ FALLÓ - %s\n", e$message))
})

cat(sprintf("\n═══════════════════════════════════════════════════════════════\n"))
cat(sprintf("RESUMEN DE PRUEBAS: %d/%d PASARON\n", passed_count, test_count))
if (passed_count == test_count) {
  cat("✓ ¡TODAS LAS PRUEBAS PASARON!\n")
  cat("La función de convolución está funcionando correctamente.\n")
} else {
  cat(sprintf("✗ %d PRUEBAS FALLARON\n", test_count - passed_count))
}
cat(sprintf("═══════════════════════════════════════════════════════════════\n"))