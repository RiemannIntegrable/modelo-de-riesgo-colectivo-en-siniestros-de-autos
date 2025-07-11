library(testthat)
source("../utils/Estimadores_severidad.R")

test_that("Estimadores_severidad ajusta correctamente la distribución Gamma", {
  
  # Generar datos que definitivamente siguen una distribución Gamma
  set.seed(123)
  datos_gamma <- rgamma(1000, shape = 2, rate = 0.5)
  
  cat("=== PRUEBA CON DATOS GAMMA PUROS ===\n")
  cat("Datos generados con rgamma(1000, shape=2, rate=0.5)\n")
  cat("Media teórica:", 2/0.5, "| Media observada:", round(mean(datos_gamma), 2), "\n")
  cat("Varianza teórica:", 2/(0.5^2), "| Varianza observada:", round(var(datos_gamma), 2), "\n\n")
  
  resultado <- Estimadores_severidad(datos_gamma)
  
  # Verificaciones básicas
  expect_true(is.list(resultado))
  expect_true("ajustes" %in% names(resultado))
  expect_true("gamma" %in% names(resultado$ajustes))
  
  # Verificar si Gamma se ajustó correctamente
  ajuste_gamma <- resultado$ajustes$gamma
  
  cat("=== RESULTADOS DEL AJUSTE GAMMA ===\n")
  cat("AIC:", ajuste_gamma$aic, "\n")
  cat("¿Es finito?:", is.finite(ajuste_gamma$aic), "\n")
  cat("Shape estimado:", ajuste_gamma$parametros$shape, "\n")
  cat("Rate estimado:", ajuste_gamma$parametros$rate, "\n\n")
  
  # La Gamma debe funcionar con datos Gamma
  expect_true(is.finite(ajuste_gamma$aic))
  expect_true(!is.na(ajuste_gamma$parametros$shape))
  expect_true(!is.na(ajuste_gamma$parametros$rate))
})

test_that("Diagnóstico de por qué falla Gamma con datos reales", {
  
  # Simular datos típicos de seguros (más realistas)
  set.seed(456)
  datos_seguros <- c(
    rgamma(800, 1.5, 0.001),  # Mayoría de reclamaciones pequeñas-medianas
    rgamma(150, 0.8, 0.0001), # Algunas reclamaciones grandes
    rgamma(50, 0.5, 0.00001)  # Pocas reclamaciones muy grandes
  )
  
  cat("=== DIAGNÓSTICO CON DATOS TIPO SEGUROS ===\n")
  cat("N:", length(datos_seguros), "\n")
  cat("Media:", round(mean(datos_seguros), 2), "\n")
  cat("Mediana:", round(median(datos_seguros), 2), "\n")
  cat("Min:", round(min(datos_seguros), 2), "\n")
  cat("Max:", round(max(datos_seguros), 2), "\n")
  cat("¿Hay zeros?:", any(datos_seguros == 0), "\n")
  cat("¿Hay valores muy pequeños (<1)?:", any(datos_seguros < 1), "\n")
  cat("¿Hay valores muy grandes (>1M)?:", any(datos_seguros > 1000000), "\n\n")
  
  # Probar ajuste manual de Gamma
  cat("=== PRUEBA AJUSTE MANUAL GAMMA ===\n")
  tryCatch({
    library(MASS)
    ajuste_manual <- fitdistr(datos_seguros, "gamma")
    cat("¡Ajuste manual exitoso!\n")
    cat("Shape:", ajuste_manual$estimate[1], "\n")
    cat("Rate:", ajuste_manual$estimate[2], "\n")
  }, error = function(e) {
    cat("Error en ajuste manual:", e$message, "\n")
  })
  
  # Probar con nuestra función
  cat("\n=== PRUEBA CON NUESTRA FUNCIÓN ===\n")
  resultado <- Estimadores_severidad(datos_seguros)
  ajuste_gamma <- resultado$ajustes$gamma
  
  cat("AIC de Gamma:", ajuste_gamma$aic, "\n")
  cat("¿Gamma funcionó?:", is.finite(ajuste_gamma$aic), "\n")
  
  # Mostrar todas las distribuciones que funcionaron
  cat("\n=== DISTRIBUCIONES QUE FUNCIONARON ===\n")
  for (dist_name in names(resultado$ajustes)) {
    aic_val <- resultado$ajustes[[dist_name]]$aic
    cat(dist_name, ":", ifelse(is.finite(aic_val), "✓", "✗"), "(AIC:", aic_val, ")\n")
  }
})

test_that("Comparación Gamma vs otras distribuciones", {
  
  # Datos mixtos para comparar
  set.seed(789)
  datos_mixtos <- c(rlnorm(500, 2, 1), rgamma(300, 2, 1), rweibull(200, 1.5, 3))
  
  cat("=== COMPARACIÓN DE DISTRIBUCIONES ===\n")
  resultado <- Estimadores_severidad(datos_mixtos)
  
  # Ordenar por AIC
  aics <- sapply(resultado$ajustes, function(x) x$aic)
  aics_finitos <- aics[is.finite(aics)]
  aics_ordenados <- sort(aics_finitos)
  
  cat("Ranking por AIC (menor = mejor):\n")
  for (i in seq_along(aics_ordenados)) {
    cat(i, ".", names(aics_ordenados)[i], "- AIC:", round(aics_ordenados[i], 2), "\n")
  }
  
  # Verificar que al menos alguna distribución funcione
  expect_true(length(aics_finitos) >= 2)
})

cat("✓ Todas las pruebas de diagnóstico completadas\n")