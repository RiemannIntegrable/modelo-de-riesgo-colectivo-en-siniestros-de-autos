source("../utils/Excluir_outliers.R")

cat("Ejecutando pruebas de Excluir_outliers...\n\n")

test_count <- 0
passed_count <- 0

run_test <- function(test_name, test_code) {
  test_count <<- test_count + 1
  cat(sprintf("Test %d: %s... ", test_count, test_name))
  
  tryCatch({
    test_code()
    passed_count <<- passed_count + 1
    cat("✓ PASÓ\n")
  }, error = function(e) {
    cat(sprintf("✗ FALLÓ - %s\n", e$message))
  })
}

set.seed(123)
datos_normales <- c(rnorm(95, mean = 50, sd = 10), c(150, 200, -50))
resultado <- Excluir_outliers(datos_normales, umbral_rareza = 0.05, silencioso = TRUE)

run_test("Estructura básica del resultado", {
  stopifnot(is.list(resultado))
  stopifnot(all(c("datos_limpios", "outliers", "indices_outliers", "scores_cbor") %in% names(resultado)))
  stopifnot(length(resultado$datos_limpios) + length(resultado$outliers) == length(datos_normales))
})

run_test("Scores normalizados correctamente", {
  stopifnot(all(resultado$scores_cbor >= 0 & resultado$scores_cbor <= 1))
  stopifnot(length(resultado$scores_cbor) == length(datos_normales))
})

set.seed(456)
datos_test <- c(rep(100, 90), rep(500, 10))
resultado_5 <- Excluir_outliers(datos_test, umbral_rareza = 0.05, silencioso = TRUE)
resultado_10 <- Excluir_outliers(datos_test, umbral_rareza = 0.10, silencioso = TRUE)

run_test("Diferentes umbrales", {
  stopifnot(length(resultado_10$outliers) >= length(resultado_5$outliers))
  stopifnot(length(resultado_10$datos_limpios) <= length(resultado_5$datos_limpios))
  stopifnot(resultado_5$estadisticas$porcentaje_outliers <= resultado_10$estadisticas$porcentaje_outliers)
})

datos_na <- c(1:20, NA, NA, 100, 200)
resultado_na <- Excluir_outliers(datos_na, umbral_rareza = 0.1, silencioso = TRUE)

run_test("Manejo de valores NA", {
  stopifnot(all(!is.na(resultado_na$datos_limpios)))
  stopifnot(all(!is.na(resultado_na$outliers)))
  stopifnot(length(resultado_na$datos_limpios) + length(resultado_na$outliers) == 22)
})

datos_evidentes <- c(rep(10, 95), c(1000, 2000, 3000, -1000, -2000))
resultado_evidentes <- Excluir_outliers(datos_evidentes, umbral_rareza = 0.05, silencioso = TRUE)

run_test("Detección de outliers evidentes", {
  stopifnot(1000 %in% resultado_evidentes$outliers)
  stopifnot(2000 %in% resultado_evidentes$outliers)
  stopifnot(-1000 %in% resultado_evidentes$outliers)
})

datos_uniformes <- rep(50, 100)
resultado_uniformes <- Excluir_outliers(datos_uniformes, umbral_rareza = 0.05, silencioso = TRUE)

run_test("Datos uniformes", {
  stopifnot(length(resultado_uniformes$outliers) <= 5)
  stopifnot(length(resultado_uniformes$datos_limpios) >= 95)
})

datos_stats <- c(1:95, rep(1000, 5))
resultado_stats <- Excluir_outliers(datos_stats, umbral_rareza = 0.1, silencioso = TRUE)

run_test("Estadísticas coherentes", {
  stopifnot(resultado_stats$estadisticas$n_original == 100)
  stopifnot(resultado_stats$estadisticas$n_outliers == length(resultado_stats$outliers))
  stopifnot(resultado_stats$estadisticas$n_limpios == length(resultado_stats$datos_limpios))
  stopifnot(resultado_stats$estadisticas$n_outliers + resultado_stats$estadisticas$n_limpios == 100)
})

cat(sprintf("\n═══════════════════════════════════════════════════════════════\n"))
cat(sprintf("RESUMEN DE PRUEBAS: %d/%d PASARON\n", passed_count, test_count))
if (passed_count == test_count) {
  cat("✓ ¡TODAS LAS PRUEBAS PASARON!\n")
} else {
  cat(sprintf("✗ %d PRUEBAS FALLARON\n", test_count - passed_count))
}
cat(sprintf("═══════════════════════════════════════════════════════════════\n"))