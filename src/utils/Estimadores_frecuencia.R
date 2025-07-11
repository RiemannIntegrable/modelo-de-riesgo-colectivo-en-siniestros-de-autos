Estimadores_frecuencia <- function(datos) {
  
  library(MASS)
  library(AER)
  
  datos <- na.omit(datos)
  n <- length(datos)
  media <- mean(datos)
  varianza <- var(datos)
  sobredispersion <- varianza / media
  
  ajustar_poisson <- function(datos) {
    lambda_est <- mean(datos)
    aic_poisson <- 2 * 1 - 2 * sum(dpois(datos, lambda_est, log = TRUE))
    return(list(
      parametros = list(lambda = lambda_est),
      aic = aic_poisson,
      loglik = sum(dpois(datos, lambda_est, log = TRUE))
    ))
  }
  
  ajustar_binomial_negativa <- function(datos) {
    tryCatch({
      ajuste <- fitdistr(datos, "negative binomial")
      return(list(
        parametros = list(size = ajuste$estimate[1], mu = ajuste$estimate[2]),
        aic = 2 * length(ajuste$estimate) - 2 * ajuste$loglik,
        loglik = ajuste$loglik
      ))
    }, error = function(e) {
      return(list(
        parametros = list(size = NA, mu = NA),
        aic = Inf,
        loglik = -Inf
      ))
    })
  }
  
  test_bondad_ajuste <- function(datos, distribucion, parametros) {
    tabla_observada <- table(datos)
    valores <- as.numeric(names(tabla_observada))
    freq_obs <- as.numeric(tabla_observada)
    
    if (distribucion == "poisson") {
      freq_esp <- n * dpois(valores, parametros$lambda)
    } else if (distribucion == "nbinom") {
      freq_esp <- n * dnbinom(valores, size = parametros$size, mu = parametros$mu)
    }
    
    freq_esp[freq_esp < 5] <- 5
    
    tryCatch({
      test_chi2 <- chisq.test(freq_obs, p = freq_esp/sum(freq_esp))
      return(list(
        estadistico = test_chi2$statistic,
        p_valor = test_chi2$p.value,
        decision = ifelse(test_chi2$p.value > 0.05, "Buen ajuste", "Mal ajuste")
      ))
    }, error = function(e) {
      return(list(
        estadistico = NA,
        p_valor = NA,
        decision = "No evaluable"
      ))
    })
  }
  
  test_cameron_trivedi <- function(datos) {
    modelo_poisson <- glm(datos ~ 1, family = poisson)
    test_ct <- dispersiontest(modelo_poisson, trafo = 1)
    return(list(
      estadistico = test_ct$statistic,
      p_valor = test_ct$p.value,
      decision = ifelse(test_ct$p.value < 0.05, "Sobredispersión", "No sobredispersión")
    ))
  }
  
  ajuste_poisson <- ajustar_poisson(datos)
  ajuste_nbinom <- ajustar_binomial_negativa(datos)
  
  bondad_poisson <- test_bondad_ajuste(datos, "poisson", ajuste_poisson$parametros)
  bondad_nbinom <- test_bondad_ajuste(datos, "nbinom", ajuste_nbinom$parametros)
  
  ct_result <- test_cameron_trivedi(datos)
  
  mejor_distribucion <- ifelse(ajuste_poisson$aic < ajuste_nbinom$aic, "Poisson", "Binomial Negativa")
  mejores_parametros <- ifelse(mejor_distribucion == "Poisson", 
                               sprintf("λ = %.4f", ajuste_poisson$parametros$lambda),
                               sprintf("size = %.4f, μ = %.4f", ajuste_nbinom$parametros$size, ajuste_nbinom$parametros$mu))
  
  cat("═══════════════════════════════════════════════════════════════════════════\n")
  cat("                           ESTIMADORES DE FRECUENCIA                        \n")
  cat("═══════════════════════════════════════════════════════════════════════════\n")
  cat(sprintf("N = %d | Media = %.4f | Varianza = %.4f | Índice Sobredispersión = %.4f\n", 
              n, media, varianza, sobredispersion))
  cat("───────────────────────────────────────────────────────────────────────────\n")
  
  cat("\n1. AJUSTE DE DISTRIBUCIONES:\n")
  cat("───────────────────────────────────────────────────────────────────────────\n")
  cat(sprintf("Poisson:           λ = %.4f | AIC = %.2f | LogLik = %.2f\n", 
              ajuste_poisson$parametros$lambda, ajuste_poisson$aic, ajuste_poisson$loglik))
  cat(sprintf("Binomial Negativa: size = %.4f, μ = %.4f | AIC = %.2f | LogLik = %.2f\n", 
              ajuste_nbinom$parametros$size, ajuste_nbinom$parametros$mu, 
              ajuste_nbinom$aic, ajuste_nbinom$loglik))
  
  cat("\n2. PRUEBAS DE BONDAD DE AJUSTE:\n")
  cat("───────────────────────────────────────────────────────────────────────────\n")
  cat(sprintf("Poisson:           χ² = %.4f | p-valor = %.4f | %s\n", 
              bondad_poisson$estadistico, bondad_poisson$p_valor, bondad_poisson$decision))
  cat(sprintf("Binomial Negativa: χ² = %.4f | p-valor = %.4f | %s\n", 
              bondad_nbinom$estadistico, bondad_nbinom$p_valor, bondad_nbinom$decision))
  
  cat("\n3. PRUEBAS DE SOBREDISPERSIÓN:\n")
  cat("───────────────────────────────────────────────────────────────────────────\n")
  cat(sprintf("Cameron-Trivedi:   z = %.4f | p-valor = %.4f | %s\n", 
              ct_result$estadistico, ct_result$p_valor, ct_result$decision))
  
  interpretacion_sobredispersion <- ifelse(sobredispersion > 1.2, "Sobredispersión", 
                                          ifelse(sobredispersion < 0.8, "Subdispersión", "Equidispersión"))
  cat(sprintf("Índice Var/Media:  %.4f | %s\n", sobredispersion, interpretacion_sobredispersion))
  
  cat("\n4. RESUMEN Y RECOMENDACIÓN:\n")
  cat("═══════════════════════════════════════════════════════════════════════════\n")
  cat(sprintf("MEJOR DISTRIBUCIÓN: %s (%s)\n", mejor_distribucion, mejores_parametros))
  
  if (sobredispersion > 1.2 && ct_result$p_valor < 0.05) {
    cat("CONCLUSIÓN: Hay evidencia de sobredispersión. Se recomienda Binomial Negativa.\n")
  } else if (sobredispersion <= 1.2 && mejor_distribucion == "Poisson") {
    cat("CONCLUSIÓN: No hay evidencia de sobredispersión. Poisson es adecuada.\n")
  } else {
    cat("CONCLUSIÓN: Resultados mixtos. Considerar ambas distribuciones.\n")
  }
  
  cat("═══════════════════════════════════════════════════════════════════════════\n")
  
  resultados <- list(
    estadisticas_descriptivas = list(
      n = n,
      media = media,
      varianza = varianza,
      indice_sobredispersion = sobredispersion
    ),
    ajustes = list(
      poisson = ajuste_poisson,
      binomial_negativa = ajuste_nbinom
    ),
    bondad_ajuste = list(
      poisson = bondad_poisson,
      binomial_negativa = bondad_nbinom
    ),
    sobredispersion = list(
      cameron_trivedi = ct_result,
      indice_dispersion = sobredispersion
    ),
    mejor_distribucion = mejor_distribucion,
    mejores_parametros = mejores_parametros
  )
  
  invisible(resultados)
}