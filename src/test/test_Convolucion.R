library(testthat)
source("../utils/Convolucion.R")

test_that("Convolucion funciona correctamente con vectores básicos", {
  
  # Test 1: Vectores simples de igual longitud
  px <- c(0.5, 0.5)  # X puede ser 0 o 1 con probabilidad 0.5 cada uno
  py <- c(0.3, 0.7)  # Y puede ser 0 o 1 con probabilidad 0.3 y 0.7
  
  resultado <- convolucion(px, py)
  
  # Resultado esperado:
  # P(Z=0) = P(X=0,Y=0) = 0.5 * 0.3 = 0.15
  # P(Z=1) = P(X=0,Y=1) + P(X=1,Y=0) = 0.5*0.7 + 0.5*0.3 = 0.35 + 0.15 = 0.50
  # P(Z=2) = P(X=1,Y=1) = 0.5 * 0.7 = 0.35
  
  esperado <- c(0.15, 0.50, 0.35)
  
  expect_equal(resultado, esperado, tolerance = 1e-10)
  expect_equal(sum(resultado), 1, tolerance = 1e-10)
})

test_that("Convolucion funciona con vectores de diferentes longitudes", {
  
  # Test 2: Vectores de diferentes longitudes
  px <- c(0.2, 0.8)           # X: longitud 2
  py <- c(0.1, 0.4, 0.5)      # Y: longitud 3
  
  resultado <- convolucion(px, py)
  
  # Verificar que la longitud sea correcta (2 + 3 - 1 = 4)
  expect_equal(length(resultado), 4)
  
  # Verificar que suma 1
  expect_equal(sum(resultado), 1, tolerance = 1e-10)
  
  # Verificar algunos valores específicos
  # P(Z=0) = P(X=0,Y=0) = 0.2 * 0.1 = 0.02
  expect_equal(resultado[1], 0.02, tolerance = 1e-10)
  
  # P(Z=3) = P(X=1,Y=2) = 0.8 * 0.5 = 0.40
  expect_equal(resultado[4], 0.40, tolerance = 1e-10)
})

test_that("Convolucion maneja casos extremos", {
  
  # Test 3: Variable determinística
  px <- c(1)      # X siempre es 0
  py <- c(0, 1)   # Y siempre es 1
  
  resultado <- convolucion(px, py)
  
  # Resultado debe ser que Z siempre es 1
  esperado <- c(0, 1)
  expect_equal(resultado, esperado, tolerance = 1e-10)
})

test_that("Convolucion valida entrada incorrecta", {
  
  # Test 4: Probabilidades negativas
  expect_error(convolucion(c(-0.1, 1.1), c(0.5, 0.5)), 
               "Las probabilidades no pueden ser negativas")
  
  # Test 5: Vectores no numéricos
  expect_error(convolucion(c("a", "b"), c(0.5, 0.5)), 
               "Los vectores de probabilidad deben ser numéricos")
})

test_that("Convolucion normaliza vectores que no suman 1", {
  
  # Test 6: Vectores que no suman 1
  px <- c(0.4, 0.4)  # Suma 0.8
  py <- c(0.6, 0.6)  # Suma 1.2
  
  expect_warning(resultado <- convolucion(px, py), 
                 "Los vectores no suman exactamente 1")
  
  # Verificar que el resultado suma 1
  expect_equal(sum(resultado), 1, tolerance = 1e-10)
})

test_that("Convolucion reproduce ejemplo teórico conocido", {
  
  # Test 7: Ejemplo con dados
  # Dado justo de 6 caras
  dado <- rep(1/6, 6)
  
  # Suma de dos dados
  resultado <- convolucion(dado, dado)
  
  # Verificar longitud (6 + 6 - 1 = 11, para sumas de 0 a 10)
  expect_equal(length(resultado), 11)
  
  # Verificar que suma 1
  expect_equal(sum(resultado), 1, tolerance = 1e-10)
  
  # Verificar simetría (las sumas equidistantes de 5 tienen igual probabilidad)
  expect_equal(resultado[1], resultado[11], tolerance = 1e-10)  # P(suma=0) = P(suma=10)
  expect_equal(resultado[2], resultado[10], tolerance = 1e-10)  # P(suma=1) = P(suma=9)
  expect_equal(resultado[3], resultado[9], tolerance = 1e-10)   # P(suma=2) = P(suma=8)
})

cat("✓ Todas las pruebas de convolución completadas exitosamente\n")