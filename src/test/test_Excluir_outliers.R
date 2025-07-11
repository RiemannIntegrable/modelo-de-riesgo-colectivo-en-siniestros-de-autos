library(testthat)
source("../utils/Excluir_outliers.R")

test_that("Excluir_outliers funciona correctamente con Z-score robusto", {
  
  set.seed(123)
  datos_normales <- c(rnorm(95, 100, 15), c(200, 300, 500))
  
  resultado <- Excluir_outliers(datos_normales, threshold = 3.5, silencioso = TRUE)
  
  expect_true(is.list(resultado))
  expect_true(all(c("datos_limpios", "outliers", "z_scores", "parametros_robustos") %in% names(resultado)))
  expect_true(length(resultado$datos_limpios) + length(resultado$outliers) == length(datos_normales))
  expect_true(all(resultado$z_scores >= 0))
})

test_that("Excluir_outliers detecta outliers extremos correctamente", {
  
  set.seed(123)
  datos_con_outliers <- c(rnorm(90, 100, 10), c(1000, 2000, 5000))
  
  resultado <- Excluir_outliers(datos_con_outliers, threshold = 3, silencioso = TRUE)
  
  expect_true(length(resultado$outliers) > 0)
  expect_true(max(resultado$outliers) > max(resultado$datos_limpios))
})

test_that("Excluir_outliers maneja diferentes valores de threshold", {
  
  set.seed(456)
  datos_test <- c(rnorm(90, 50, 10), c(150, 200, 250))
  
  resultado_agresivo <- Excluir_outliers(datos_test, threshold = 2, silencioso = TRUE)
  resultado_conservador <- Excluir_outliers(datos_test, threshold = 4, silencioso = TRUE)
  
  expect_true(length(resultado_agresivo$outliers) >= length(resultado_conservador$outliers))
  expect_true(length(resultado_agresivo$datos_limpios) <= length(resultado_conservador$datos_limpios))
})

test_that("Excluir_outliers es robusto a outliers extremos", {
  
  set.seed(789)
  datos_robustos <- c(rnorm(80, 10, 1), rep(1000000, 20))
  
  resultado <- Excluir_outliers(datos_robustos, threshold = 3.5, silencioso = TRUE)
  
  expect_true(length(resultado$outliers) > 0)
  expect_true(length(resultado$datos_limpios) > 0)
  expect_true(max(resultado$outliers) > max(resultado$datos_limpios))
})

test_that("Excluir_outliers maneja datos con pocos elementos", {
  
  datos_pocos <- c(1, 2, 3)
  
  expect_warning(resultado <- Excluir_outliers(datos_pocos, threshold = 3.5, silencioso = TRUE))
  expect_equal(length(resultado$outliers), 0)
  expect_equal(length(resultado$datos_limpios), 3)
})

test_that("Excluir_outliers maneja datos con valores NA y negativos", {
  
  datos_mixtos <- c(rnorm(50, 25, 5), NA, -5, 0, NA)
  
  resultado <- Excluir_outliers(datos_mixtos, threshold = 3.5, silencioso = TRUE)
  
  expect_true(all(resultado$datos_limpios > 0))
  expect_true(all(!is.na(resultado$datos_limpios)))
  expect_true(resultado$estadisticas$n_original >= 50)
  expect_true(resultado$estadisticas$n_positivos <= resultado$estadisticas$n_original)
})

test_that("Excluir_outliers funciona con datos básicos", {
  
  datos_basicos <- c(1:20, 100)
  
  resultado <- Excluir_outliers(datos_basicos, threshold = 3, silencioso = TRUE)
  
  expect_true(length(resultado$datos_limpios) + length(resultado$outliers) == length(datos_basicos))
  expect_true(100 %in% resultado$outliers)
})

test_that("Excluir_outliers preserva índices correctamente", {
  
  datos_ordenados <- c(1:10, 1000)
  
  resultado <- Excluir_outliers(datos_ordenados, threshold = 3, silencioso = TRUE)
  
  expect_true(all(resultado$indices_outliers <= length(datos_ordenados)))
  expect_true(all(resultado$indices_outliers > 0))
  expect_equal(datos_ordenados[resultado$indices_outliers], resultado$outliers)
})

test_that("Excluir_outliers retorna estadísticas correctas", {
  
  set.seed(999)
  datos_stats <- c(rnorm(95, 50, 10), c(200, 300))
  
  resultado <- Excluir_outliers(datos_stats, threshold = 3.5, silencioso = TRUE)
  
  expect_equal(resultado$estadisticas$n_original, 97)
  expect_equal(resultado$estadisticas$n_positivos, 97)
  expect_equal(resultado$estadisticas$n_outliers, length(resultado$outliers))
  expect_equal(resultado$estadisticas$n_limpios, length(resultado$datos_limpios))
  expect_equal(resultado$estadisticas$n_outliers + resultado$estadisticas$n_limpios, 97)
  expect_true(resultado$estadisticas$porcentaje_outliers >= 0)
  expect_true(resultado$estadisticas$porcentaje_outliers <= 100)
})

test_that("Excluir_outliers threshold funciona correctamente", {
  
  datos_simple <- c(1:50, 200)
  
  resultado_agresivo <- Excluir_outliers(datos_simple, threshold = 2, silencioso = TRUE)
  resultado_conservador <- Excluir_outliers(datos_simple, threshold = 4, silencioso = TRUE)
  
  expect_true(length(resultado_agresivo$outliers) >= length(resultado_conservador$outliers))
})

cat("✓ Todas las pruebas del método Z-score robusto completadas exitosamente\n")