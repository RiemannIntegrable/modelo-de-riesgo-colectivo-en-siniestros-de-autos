test_sobredispersion <- function(datos) {
  
  library(AER)
  
  datos <- na.omit(datos)
  n <- length(datos)
  media <- mean(datos)
  varianza <- var(datos)
  sobredispersion <- varianza / media
  
  test_cameron_trivedi <- function(datos) {
    modelo_poisson <- glm(datos ~ 1, family = poisson)
    test_ct <- dispersiontest(modelo_poisson, trafo = 1)
    return(list(
      estadistico = test_ct$statistic,
      p_valor = test_ct$p.value,
      decision = ifelse(test_ct$p.value < 0.05, "Sobredispersión", "No sobredispersión")
    ))
  }
  
  test_indice_dispersion <- function(datos) {
    media <- mean(datos)
    varianza <- var(datos)
    n <- length(datos)
    estadistico <- (n - 1) * varianza / media
    p_valor <- 1 - pchisq(estadistico, df = n - 1)
    decision <- ifelse(p_valor < 0.05, "Sobredispersión", "No sobredispersión")
    return(list(
      estadistico = estadistico,
      p_valor = p_valor,
      decision = decision
    ))
  }
  
  test_cociente_varianza_media <- function(datos) {
    ratio <- var(datos) / mean(datos)
    decision <- ifelse(ratio > 1.2, "Sobredispersión", 
                      ifelse(ratio < 0.8, "Subdispersión", "Equidispersión"))
    return(list(
      estadistico = ratio,
      p_valor = NA,
      decision = decision
    ))
  }
  
  ct_result <- test_cameron_trivedi(datos)
  id_result <- test_indice_dispersion(datos)
  vm_result <- test_cociente_varianza_media(datos)
  
  resultados <- data.frame(
    Métrica = c("Sobredispersión (Var/Media)", 
                "Test Cameron-Trivedi",
                "Test Índice Dispersión", 
                "Test Cociente Var/Media"),
    Estadístico = c(round(sobredispersion, 3),
                   round(ct_result$estadistico, 3),
                   round(id_result$estadistico, 3),
                   round(vm_result$estadistico, 3)),
    `P-valor` = c("-",
                 format.pval(ct_result$p_valor, digits = 3),
                 format.pval(id_result$p_valor, digits = 3),
                 "-"),
    Decisión = c(ifelse(sobredispersion > 1.2, "Sobredispersión", 
                       ifelse(sobredispersion < 0.8, "Subdispersión", "Equidispersión")),
                ct_result$decision,
                id_result$decision,
                vm_result$decision),
    stringsAsFactors = FALSE
  )
  
  names(resultados)[3] <- "P-valor"
  
  cat("═══════════════════════════════════════════════════════════════\n")
  cat("                    TESTS DE SOBREDISPERSIÓN                    \n")
  cat("═══════════════════════════════════════════════════════════════\n")
  cat(sprintf("N = %d | Media = %.3f | Varianza = %.3f\n", n, media, varianza))
  cat("───────────────────────────────────────────────────────────────\n")
  
  for (i in 1:nrow(resultados)) {
    cat(sprintf("%-25s | %8s | %8s | %15s\n", 
                resultados$Métrica[i],
                resultados$Estadístico[i],
                resultados$`P-valor`[i],
                resultados$Decisión[i]))
  }
  
  cat("═══════════════════════════════════════════════════════════════\n")
  
  consenso <- sum(grepl("Sobredispersión", resultados$Decisión))
  if (consenso >= 3) {
    cat("CONCLUSIÓN: Evidencia FUERTE de sobredispersión\n")
  } else if (consenso >= 2) {
    cat("CONCLUSIÓN: Evidencia MODERADA de sobredispersión\n")
  } else {
    cat("CONCLUSIÓN: Evidencia DÉBIL o NULA de sobredispersión\n")
  }
  
  cat("═══════════════════════════════════════════════════════════════\n")
  
  invisible(resultados)
}