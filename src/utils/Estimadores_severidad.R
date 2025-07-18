Estimadores_severidad <- function(datos) {
  
  suppressWarnings({
    library(MASS)
    library(actuar)
  
  datos <- na.omit(datos[datos > 0])
  n <- length(datos)
  media <- mean(datos)
  varianza <- var(datos)
  mediana <- median(datos)
  cv <- sd(datos) / media
  
  ajustar_normal <- function(datos) {
    tryCatch({
      ajuste <- fitdistr(datos, "normal")
      return(list(
        parametros = list(mean = ajuste$estimate[1], sd = ajuste$estimate[2]),
        aic = 2 * length(ajuste$estimate) - 2 * ajuste$loglik,
        loglik = ajuste$loglik,
        bic = log(length(datos)) * length(ajuste$estimate) - 2 * ajuste$loglik
      ))
    }, error = function(e) {
      return(list(
        parametros = list(mean = NA, sd = NA),
        aic = Inf,
        loglik = -Inf,
        bic = Inf
      ))
    })
  }
  
  ajustar_gamma <- function(datos) {
    tryCatch({
      # Escalar datos para mejorar convergencia
      factor_escala <- median(datos)
      datos_escalados <- datos / factor_escala
      
      # Ajustar con valores iniciales mejorados
      media_esc <- mean(datos_escalados)
      var_esc <- var(datos_escalados)
      shape_inicial <- media_esc^2 / var_esc
      rate_inicial <- media_esc / var_esc
      
      ajuste <- suppressWarnings(fitdistr(datos_escalados, "gamma", 
                                         start = list(shape = shape_inicial, rate = rate_inicial),
                                         lower = c(0.001, 0.001)))
      
      # Reescalar parámetros
      shape_final <- ajuste$estimate[1]
      rate_final <- ajuste$estimate[2] / factor_escala
      
      # Calcular log-likelihood con datos originales
      loglik_original <- sum(dgamma(datos, shape = shape_final, rate = rate_final, log = TRUE))
      
      return(list(
        parametros = list(shape = shape_final, rate = rate_final),
        aic = 2 * length(ajuste$estimate) - 2 * loglik_original,
        loglik = loglik_original,
        bic = log(length(datos)) * length(ajuste$estimate) - 2 * loglik_original
      ))
    }, error = function(e) {
      return(list(
        parametros = list(shape = NA, rate = NA),
        aic = Inf,
        loglik = -Inf,
        bic = Inf
      ))
    })
  }
  
  ajustar_weibull <- function(datos) {
    tryCatch({
      ajuste <- fitdistr(datos, "weibull")
      return(list(
        parametros = list(shape = ajuste$estimate[1], scale = ajuste$estimate[2]),
        aic = 2 * length(ajuste$estimate) - 2 * ajuste$loglik,
        loglik = ajuste$loglik,
        bic = log(length(datos)) * length(ajuste$estimate) - 2 * ajuste$loglik
      ))
    }, error = function(e) {
      return(list(
        parametros = list(shape = NA, scale = NA),
        aic = Inf,
        loglik = -Inf,
        bic = Inf
      ))
    })
  }
  
  ajustar_lognormal <- function(datos) {
    tryCatch({
      ajuste <- fitdistr(datos, "lognormal")
      return(list(
        parametros = list(meanlog = ajuste$estimate[1], sdlog = ajuste$estimate[2]),
        aic = 2 * length(ajuste$estimate) - 2 * ajuste$loglik,
        loglik = ajuste$loglik,
        bic = log(length(datos)) * length(ajuste$estimate) - 2 * ajuste$loglik
      ))
    }, error = function(e) {
      return(list(
        parametros = list(meanlog = NA, sdlog = NA),
        aic = Inf,
        loglik = -Inf,
        bic = Inf
      ))
    })
  }
  
  ajustar_pareto <- function(datos) {
    tryCatch({
      if (requireNamespace("actuar", quietly = TRUE)) {
        inicio <- list(shape = 1, scale = min(datos))
        ajuste <- suppressWarnings(fitdistr(datos, dpareto, start = inicio, shape = "shape", scale = "scale"))
        return(list(
          parametros = list(shape = ajuste$estimate[1], scale = ajuste$estimate[2]),
          aic = 2 * length(ajuste$estimate) - 2 * ajuste$loglik,
          loglik = ajuste$loglik,
          bic = log(length(datos)) * length(ajuste$estimate) - 2 * ajuste$loglik
        ))
      } else {
        return(list(
          parametros = list(shape = NA, scale = NA),
          aic = Inf,
          loglik = -Inf,
          bic = Inf
        ))
      }
    }, error = function(e) {
      return(list(
        parametros = list(shape = NA, scale = NA),
        aic = Inf,
        loglik = -Inf,
        bic = Inf
      ))
    })
  }
  
  
  ajustar_inv_gaussian <- function(datos) {
    tryCatch({
      if (requireNamespace("statmod", quietly = TRUE)) {
        # Usar método de momentos para valores iniciales
        media <- mean(datos)
        var_datos <- var(datos)
        lambda_inicial <- media^3 / var_datos
        mu_inicial <- media
        
        # Función de densidad y log-likelihood para inverse gaussian
        dinvgaus <- function(x, mu, lambda) {
          sqrt(lambda / (2 * pi * x^3)) * exp(-lambda * (x - mu)^2 / (2 * mu^2 * x))
        }
        
        ajuste <- suppressWarnings(fitdistr(datos, dinvgaus, start = list(mu = mu_inicial, lambda = lambda_inicial), 
                                          lower = c(0.001, 0.001)))
        
        return(list(
          parametros = list(mu = ajuste$estimate[1], lambda = ajuste$estimate[2]),
          aic = 2 * length(ajuste$estimate) - 2 * ajuste$loglik,
          loglik = ajuste$loglik,
          bic = log(length(datos)) * length(ajuste$estimate) - 2 * ajuste$loglik
        ))
      } else {
        return(list(
          parametros = list(mu = NA, lambda = NA),
          aic = Inf,
          loglik = -Inf,
          bic = Inf
        ))
      }
    }, error = function(e) {
      return(list(
        parametros = list(mu = NA, lambda = NA),
        aic = Inf,
        loglik = -Inf,
        bic = Inf
      ))
    })
  }
  
  ajustar_burr <- function(datos) {
    tryCatch({
      if (requireNamespace("actuar", quietly = TRUE)) {
        # Valores iniciales basados en características de los datos
        media <- mean(datos)
        inicio <- list(shape1 = 1, shape2 = 2, scale = media)
        
        ajuste <- suppressWarnings(fitdistr(datos, dburr, start = inicio, 
                                          shape1 = "shape1", shape2 = "shape2", scale = "scale",
                                          lower = c(0.001, 0.001, 0.001)))
        
        return(list(
          parametros = list(shape1 = ajuste$estimate[1], shape2 = ajuste$estimate[2], scale = ajuste$estimate[3]),
          aic = 2 * length(ajuste$estimate) - 2 * ajuste$loglik,
          loglik = ajuste$loglik,
          bic = log(length(datos)) * length(ajuste$estimate) - 2 * ajuste$loglik
        ))
      } else {
        return(list(
          parametros = list(shape1 = NA, shape2 = NA, scale = NA),
          aic = Inf,
          loglik = -Inf,
          bic = Inf
        ))
      }
    }, error = function(e) {
      return(list(
        parametros = list(shape1 = NA, shape2 = NA, scale = NA),
        aic = Inf,
        loglik = -Inf,
        bic = Inf
      ))
    })
  }
  
  test_ks <- function(datos, distribucion, parametros) {
    tryCatch({
      if (distribucion == "normal") {
        test_result <- suppressWarnings(ks.test(datos, "pnorm", parametros$mean, parametros$sd))
      } else if (distribucion == "gamma") {
        test_result <- suppressWarnings(ks.test(datos, "pgamma", parametros$shape, parametros$rate))
      } else if (distribucion == "weibull") {
        test_result <- suppressWarnings(ks.test(datos, "pweibull", parametros$shape, parametros$scale))
      } else if (distribucion == "lognormal") {
        test_result <- suppressWarnings(ks.test(datos, "plnorm", parametros$meanlog, parametros$sdlog))
      } else if (distribucion == "inv_gaussian") {
        if (requireNamespace("statmod", quietly = TRUE)) {
          pinvgaus <- function(x, mu, lambda) {
            pnorm(sqrt(lambda/x) * (x/mu - 1)) + exp(2*lambda/mu) * pnorm(-sqrt(lambda/x) * (x/mu + 1))
          }
          test_result <- suppressWarnings(ks.test(datos, pinvgaus, parametros$mu, parametros$lambda))
        } else {
          return(list(estadistico = NA, p_valor = NA, decision = "No evaluable"))
        }
      } else if (distribucion == "pareto") {
        if (requireNamespace("actuar", quietly = TRUE)) {
          test_result <- suppressWarnings(ks.test(datos, ppareto, parametros$shape, parametros$scale))
        } else {
          return(list(estadistico = NA, p_valor = NA, decision = "No evaluable"))
        }
      } else if (distribucion == "burr") {
        if (requireNamespace("actuar", quietly = TRUE)) {
          test_result <- suppressWarnings(ks.test(datos, pburr, parametros$shape1, parametros$shape2, parametros$scale))
        } else {
          return(list(estadistico = NA, p_valor = NA, decision = "No evaluable"))
        }
      }
      
      return(list(
        estadistico = test_result$statistic,
        p_valor = test_result$p.value,
        decision = ifelse(test_result$p.value > 0.05, "Buen ajuste", "Mal ajuste")
      ))
    }, error = function(e) {
      return(list(
        estadistico = NA,
        p_valor = NA,
        decision = "No evaluable"
      ))
    })
  }
  
  test_anderson_darling <- function(datos, distribucion, parametros) {
    tryCatch({
      if (requireNamespace("nortest", quietly = TRUE)) {
        if (distribucion == "normal") {
          datos_std <- (datos - parametros$mean) / parametros$sd
          test_result <- nortest::ad.test(datos_std)
        } else {
          return(list(estadistico = NA, p_valor = NA, decision = "No disponible"))
        }
        
        return(list(
          estadistico = test_result$statistic,
          p_valor = test_result$p.value,
          decision = ifelse(test_result$p.value > 0.05, "Buen ajuste", "Mal ajuste")
        ))
      } else {
        return(list(estadistico = NA, p_valor = NA, decision = "Paquete no disponible"))
      }
    }, error = function(e) {
      return(list(
        estadistico = NA,
        p_valor = NA,
        decision = "No evaluable"
      ))
    })
  }
  
  ajuste_normal <- ajustar_normal(datos)
  ajuste_gamma <- ajustar_gamma(datos)
  ajuste_weibull <- ajustar_weibull(datos)
  ajuste_lognormal <- ajustar_lognormal(datos)
  ajuste_inv_gaussian <- ajustar_inv_gaussian(datos)
  ajuste_pareto <- ajustar_pareto(datos)
  ajuste_burr <- ajustar_burr(datos)
  
  ajustes <- list(
    normal = ajuste_normal,
    gamma = ajuste_gamma,
    weibull = ajuste_weibull,
    lognormal = ajuste_lognormal,
    inv_gaussian = ajuste_inv_gaussian,
    pareto = ajuste_pareto,
    burr = ajuste_burr
  )
  
  aics <- sapply(ajustes, function(x) x$aic)
  mejor_aic <- names(aics)[which.min(aics)]
  
  bics <- sapply(ajustes, function(x) x$bic)
  mejor_bic <- names(bics)[which.min(bics)]
  
  ks_normal <- test_ks(datos, "normal", ajuste_normal$parametros)
  ks_gamma <- test_ks(datos, "gamma", ajuste_gamma$parametros)
  ks_weibull <- test_ks(datos, "weibull", ajuste_weibull$parametros)
  ks_lognormal <- test_ks(datos, "lognormal", ajuste_lognormal$parametros)
  ks_inv_gaussian <- test_ks(datos, "inv_gaussian", ajuste_inv_gaussian$parametros)
  ks_pareto <- test_ks(datos, "pareto", ajuste_pareto$parametros)
  ks_burr <- test_ks(datos, "burr", ajuste_burr$parametros)
  
  ad_normal <- test_anderson_darling(datos, "normal", ajuste_normal$parametros)
  
  cat("═══════════════════════════════════════════════════════════════════════════\n")
  cat("                           ESTIMADORES DE SEVERIDAD                         \n")
  cat("═══════════════════════════════════════════════════════════════════════════\n")
  cat(sprintf("N = %d | Media = %.2f | Mediana = %.2f | CV = %.4f\n", 
              n, media, mediana, cv))
  cat("───────────────────────────────────────────────────────────────────────────\n")
  
  cat("\n1. AJUSTE DE DISTRIBUCIONES:\n")
  cat("───────────────────────────────────────────────────────────────────────────\n")
  
  format_params <- function(dist_name, params) {
    if (dist_name == "normal") {
      sprintf("μ=%.2f, σ=%.2f", params$mean, params$sd)
    } else if (dist_name == "gamma") {
      sprintf("α=%.4f, β=%.4f", params$shape, params$rate)
    } else if (dist_name == "weibull") {
      sprintf("k=%.4f, λ=%.2f", params$shape, params$scale)
    } else if (dist_name == "lognormal") {
      sprintf("μ=%.4f, σ=%.4f", params$meanlog, params$sdlog)
    } else if (dist_name == "inv_gaussian") {
      sprintf("μ=%.2f, λ=%.4f", params$mu, params$lambda)
    } else if (dist_name == "pareto") {
      sprintf("α=%.4f, θ=%.2f", params$shape, params$scale)
    } else if (dist_name == "burr") {
      sprintf("α=%.4f, γ=%.4f, θ=%.2f", params$shape1, params$shape2, params$scale)
    }
  }
  
  for (dist_name in names(ajustes)) {
    ajuste <- ajustes[[dist_name]]
    if (!is.na(ajuste$aic) && ajuste$aic != Inf) {
      params_str <- format_params(dist_name, ajuste$parametros)
      cat(sprintf("%-12s: %s | AIC=%.2f | BIC=%.2f\n", 
                  stringr::str_to_title(dist_name), params_str, ajuste$aic, ajuste$bic))
    }
  }
  
  cat("\n2. PRUEBAS DE BONDAD DE AJUSTE (Kolmogorov-Smirnov):\n")
  cat("───────────────────────────────────────────────────────────────────────────\n")
  
  ks_tests <- list(
    normal = ks_normal,
    gamma = ks_gamma,
    weibull = ks_weibull,
    lognormal = ks_lognormal,
    inv_gaussian = ks_inv_gaussian,
    pareto = ks_pareto,
    burr = ks_burr
  )
  
  for (dist_name in names(ks_tests)) {
    test_result <- ks_tests[[dist_name]]
    ajuste <- ajustes[[dist_name]]
    if (!is.na(ajuste$aic) && ajuste$aic != Inf && !is.na(test_result$estadistico)) {
      cat(sprintf("%-12s: D=%.4f | p-valor=%.4f | %s\n", 
                  stringr::str_to_title(dist_name), 
                  test_result$estadistico, test_result$p_valor, test_result$decision))
    }
  }
  
  if (!is.na(ad_normal$estadistico)) {
    cat("\n3. PRUEBA ANDERSON-DARLING (Normal):\n")
    cat("───────────────────────────────────────────────────────────────────────────\n")
    cat(sprintf("Normal       : A²=%.4f | p-valor=%.4f | %s\n", 
                ad_normal$estadistico, ad_normal$p_valor, ad_normal$decision))
  }
  
  cat("\n4. RESUMEN Y RECOMENDACIÓN:\n")
  cat("═══════════════════════════════════════════════════════════════════════════\n")
  
  if (mejor_aic == mejor_bic) {
    mejor_dist <- mejor_aic
    cat(sprintf("MEJOR DISTRIBUCIÓN (AIC y BIC): %s\n", stringr::str_to_title(mejor_dist)))
  } else {
    cat(sprintf("MEJOR POR AIC: %s | MEJOR POR BIC: %s\n", 
                stringr::str_to_title(mejor_aic), stringr::str_to_title(mejor_bic)))
    mejor_dist <- mejor_aic
  }
  
  mejor_ajuste <- ajustes[[mejor_dist]]
  mejor_params <- format_params(mejor_dist, mejor_ajuste$parametros)
  cat(sprintf("PARÁMETROS RECOMENDADOS: %s\n", mejor_params))
  
  mejor_ks <- ks_tests[[mejor_dist]]
  if (!is.na(mejor_ks$p_valor)) {
    if (mejor_ks$p_valor > 0.05) {
      cat("CONCLUSIÓN: El ajuste es estadísticamente aceptable.\n")
    } else {
      cat("CONCLUSIÓN: El ajuste puede no ser óptimo (rechaza hipótesis nula).\n")
    }
  }
  
  cat("═══════════════════════════════════════════════════════════════════════════\n")
  
  resultados <- list(
    estadisticas_descriptivas = list(
      n = n,
      media = media,
      varianza = varianza,
      mediana = mediana,
      cv = cv
    ),
    ajustes = ajustes,
    mejor_distribucion_aic = mejor_aic,
    mejor_distribucion_bic = mejor_bic,
    bondad_ajuste_ks = ks_tests,
    bondad_ajuste_ad = list(normal = ad_normal),
    recomendacion = list(
      distribucion = mejor_dist,
      parametros = mejor_params
    )
  )
  
  invisible(resultados)
  })
}