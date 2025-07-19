test_independencia <- function(data, alpha = 0.05) {
  library(knitr)
  library(xtable)
  
  if (!is.data.frame(data) || ncol(data) < 2) {
    stop("Se requiere un dataframe con al menos 2 columnas")
  }
  
  if (any(data < 0, na.rm = TRUE) || any(!is.finite(as.matrix(data)), na.rm = TRUE)) {
    stop("Los datos deben ser valores de conteo no negativos y finitos")
  }
  
  resultados <- data.frame(
    Test = character(0),
    Estadistico = numeric(0),
    p_valor = numeric(0),
    Conclusion = character(0),
    stringsAsFactors = FALSE
  )
  
  n_vars <- ncol(data)
  nombres_vars <- colnames(data)
  
  # 1. Test Chi-cuadrado de Pearson (tabla de contingencia)
  if (n_vars == 2) {
    tabla_cont <- table(data[,1], data[,2])
    chi_test <- chisq.test(tabla_cont)
    conclusion_chi <- ifelse(chi_test$p.value < alpha, "Dependientes", "Independientes")
    
    resultados <- rbind(resultados, data.frame(
      Test = "Chi-cuadrado Pearson",
      Estadistico = round(chi_test$statistic, 4),
      p_valor = round(chi_test$p.value, 6),
      Conclusion = conclusion_chi
    ))
  }
  
  # 2. Correlación de Spearman (todas las combinaciones)
  cor_spearman <- cor(data, method = "spearman", use = "complete.obs")
  
  for (i in 1:(n_vars-1)) {
    for (j in (i+1):n_vars) {
      cor_test <- cor.test(data[,i], data[,j], method = "spearman")
      conclusion_spear <- ifelse(cor_test$p.value < alpha, "Dependientes", "Independientes")
      
      resultados <- rbind(resultados, data.frame(
        Test = paste("Spearman:", nombres_vars[i], "vs", nombres_vars[j]),
        Estadistico = round(cor_test$estimate, 4),
        p_valor = round(cor_test$p.value, 6),
        Conclusion = conclusion_spear
      ))
    }
  }
  
  # 3. Correlación de Kendall (todas las combinaciones)
  for (i in 1:(n_vars-1)) {
    for (j in (i+1):n_vars) {
      kendall_test <- cor.test(data[,i], data[,j], method = "kendall")
      conclusion_kendall <- ifelse(kendall_test$p.value < alpha, "Dependientes", "Independientes")
      
      resultados <- rbind(resultados, data.frame(
        Test = paste("Kendall:", nombres_vars[i], "vs", nombres_vars[j]),
        Estadistico = round(kendall_test$estimate, 4),
        p_valor = round(kendall_test$p.value, 6),
        Conclusion = conclusion_kendall
      ))
    }
  }
  
  # 4. Test de Kruskal-Wallis (si hay más de 2 variables)
  if (n_vars > 2) {
    data_long <- reshape2::melt(data.frame(data, row = 1:nrow(data)), 
                               id.vars = "row", variable.name = "Variable", value.name = "Valor")
    kw_test <- kruskal.test(Valor ~ Variable, data = data_long)
    conclusion_kw <- ifelse(kw_test$p.value < alpha, "Dependientes", "Independientes")
    
    resultados <- rbind(resultados, data.frame(
      Test = "Kruskal-Wallis",
      Estadistico = round(kw_test$statistic, 4),
      p_valor = round(kw_test$p.value, 6),
      Conclusion = conclusion_kw
    ))
  }
  
  # 5. Test de Friedman (datos relacionados)
  if (n_vars > 2 && nrow(data) > 1) {
    tryCatch({
      friedman_test <- friedman.test(as.matrix(data))
      conclusion_friedman <- ifelse(friedman_test$p.value < alpha, "Dependientes", "Independientes")
      
      resultados <- rbind(resultados, data.frame(
        Test = "Friedman",
        Estadistico = round(friedman_test$statistic, 4),
        p_valor = round(friedman_test$p.value, 6),
        Conclusion = conclusion_friedman
      ))
    }, error = function(e) {
      cat("Advertencia: No se pudo ejecutar el test de Friedman\n")
    })
  }
  
  # 6. Test exacto de Fisher (para variables dicotómicas)
  if (n_vars == 2) {
    max_vals <- sapply(data, max, na.rm = TRUE)
    if (all(max_vals <= 1)) {
      tabla_fisher <- table(data[,1], data[,2])
      fisher_test <- fisher.test(tabla_fisher)
      conclusion_fisher <- ifelse(fisher_test$p.value < alpha, "Dependientes", "Independientes")
      
      resultados <- rbind(resultados, data.frame(
        Test = "Fisher Exacto",
        Estadistico = NA,
        p_valor = round(fisher_test$p.value, 6),
        Conclusion = conclusion_fisher
      ))
    }
  }
  
  # Conclusión general
  prop_dependientes <- sum(resultados$Conclusion == "Dependientes") / nrow(resultados)
  
  cat("\n")
  cat(paste(rep("=", 80), collapse = ""), "\n")
  cat("               TESTS DE INDEPENDENCIA PARA VARIABLES DE CONTEO\n")
  cat(paste(rep("=", 80), collapse = ""), "\n")
  cat("Nivel de significancia:", alpha, "\n")
  cat("Variables analizadas:", paste(nombres_vars, collapse = ", "), "\n")
  cat("Número de observaciones:", nrow(data), "\n")
  cat(paste(rep("-", 80), collapse = ""), "\n")
  
  print(kable(resultados, format = "simple", digits = 6, align = c("l", "r", "r", "c")))
  
  cat("\n")
  cat(paste(rep("-", 80), collapse = ""), "\n")
  cat("CONCLUSIÓN GENERAL:\n")
  cat(paste(rep("-", 80), collapse = ""), "\n")
  
  if (prop_dependientes >= 0.7) {
    cat("EVIDENCIA FUERTE DE DEPENDENCIA entre las variables.\n")
    cat(sprintf("%.1f%% de los tests indican dependencia.\n", prop_dependientes * 100))
  } else if (prop_dependientes >= 0.3) {
    cat("EVIDENCIA MIXTA sobre la independencia de las variables.\n")
    cat(sprintf("%.1f%% de los tests indican dependencia.\n", prop_dependientes * 100))
    cat("Se recomienda análisis adicional.\n")
  } else {
    cat("EVIDENCIA DE INDEPENDENCIA entre las variables.\n")
    cat(sprintf("%.1f%% de los tests indican dependencia.\n", prop_dependientes * 100))
  }
  
  cat("\nNOTAS:\n")
  cat("- Spearman y Kendall miden dependencia monotónica\n")
  cat("- Chi-cuadrado evalúa independencia categórica\n")
  cat("- Kruskal-Wallis compara distribuciones entre grupos\n")
  cat("- Friedman evalúa diferencias en medidas repetidas\n")
  cat(paste(rep("=", 80), collapse = ""), "\n")
  
  return(invisible(resultados))
}

test_independencia_parejas <- function(data, alpha = 0.05) {
  if (!is.data.frame(data) || ncol(data) < 2) {
    stop("Se requiere un dataframe con al menos 2 columnas")
  }
  
  nombres_vars <- colnames(data)
  n_vars <- ncol(data)
  
  cat("\n")
  cat(paste(rep("=", 60), collapse = ""), "\n")
  cat("         ANÁLISIS DE INDEPENDENCIA POR PAREJAS\n")
  cat(paste(rep("=", 60), collapse = ""), "\n")
  
  for (i in 1:(n_vars-1)) {
    for (j in (i+1):n_vars) {
      cat("\n")
      cat(sprintf("PAREJA: %s vs %s\n", nombres_vars[i], nombres_vars[j]))
      cat(paste(rep("-", 40), collapse = ""), "\n")
      
      pareja_data <- data[, c(i, j)]
      pareja_data <- pareja_data[complete.cases(pareja_data), ]
      
      test_independencia(pareja_data, alpha)
    }
  }
}

test_independencia_severidad <- function(data, alpha = 0.05) {
  library(knitr)
  library(nortest)
  
  if (!is.data.frame(data) || ncol(data) < 2) {
    stop("Se requiere un dataframe con al menos 2 columnas")
  }
  
  if (any(data <= 0, na.rm = TRUE) || any(!is.finite(as.matrix(data)), na.rm = TRUE)) {
    stop("Los datos de severidad deben ser valores positivos y finitos")
  }
  
  resultados <- data.frame(
    Test = character(0),
    Estadistico = numeric(0),
    p_valor = numeric(0),
    Conclusion = character(0),
    stringsAsFactors = FALSE
  )
  
  n_vars <- ncol(data)
  nombres_vars <- colnames(data)
  
  # 1. Correlación de Pearson (lineal)
  for (i in 1:(n_vars-1)) {
    for (j in (i+1):n_vars) {
      pearson_test <- cor.test(data[,i], data[,j], method = "pearson")
      conclusion_pearson <- ifelse(pearson_test$p.value < alpha, "Dependientes", "Independientes")
      
      resultados <- rbind(resultados, data.frame(
        Test = paste("Pearson:", nombres_vars[i], "vs", nombres_vars[j]),
        Estadistico = round(pearson_test$estimate, 4),
        p_valor = round(pearson_test$p.value, 6),
        Conclusion = conclusion_pearson
      ))
    }
  }
  
  # 2. Correlación de Spearman (monotónica)
  for (i in 1:(n_vars-1)) {
    for (j in (i+1):n_vars) {
      spearman_test <- cor.test(data[,i], data[,j], method = "spearman")
      conclusion_spear <- ifelse(spearman_test$p.value < alpha, "Dependientes", "Independientes")
      
      resultados <- rbind(resultados, data.frame(
        Test = paste("Spearman:", nombres_vars[i], "vs", nombres_vars[j]),
        Estadistico = round(spearman_test$estimate, 4),
        p_valor = round(spearman_test$p.value, 6),
        Conclusion = conclusion_spear
      ))
    }
  }
  
  # 3. Correlación de Kendall
  for (i in 1:(n_vars-1)) {
    for (j in (i+1):n_vars) {
      kendall_test <- cor.test(data[,i], data[,j], method = "kendall")
      conclusion_kendall <- ifelse(kendall_test$p.value < alpha, "Dependientes", "Independientes")
      
      resultados <- rbind(resultados, data.frame(
        Test = paste("Kendall:", nombres_vars[i], "vs", nombres_vars[j]),
        Estadistico = round(kendall_test$estimate, 4),
        p_valor = round(kendall_test$p.value, 6),
        Conclusion = conclusion_kendall
      ))
    }
  }
  
  # 4. Test de Kolmogorov-Smirnov (comparación de distribuciones)
  for (i in 1:(n_vars-1)) {
    for (j in (i+1):n_vars) {
      ks_test <- ks.test(data[,i], data[,j])
      conclusion_ks <- ifelse(ks_test$p.value < alpha, "Distribuciones diferentes", "Distribuciones similares")
      
      resultados <- rbind(resultados, data.frame(
        Test = paste("Kolmogorov-Smirnov:", nombres_vars[i], "vs", nombres_vars[j]),
        Estadistico = round(ks_test$statistic, 4),
        p_valor = round(ks_test$p.value, 6),
        Conclusion = conclusion_ks
      ))
    }
  }
  
  # 5. Test de Wilcoxon (Mann-Whitney U)
  for (i in 1:(n_vars-1)) {
    for (j in (i+1):n_vars) {
      wilcox_test <- wilcox.test(data[,i], data[,j])
      conclusion_wilcox <- ifelse(wilcox_test$p.value < alpha, "Medianas diferentes", "Medianas similares")
      
      resultados <- rbind(resultados, data.frame(
        Test = paste("Wilcoxon:", nombres_vars[i], "vs", nombres_vars[j]),
        Estadistico = round(wilcox_test$statistic, 4),
        p_valor = round(wilcox_test$p.value, 6),
        Conclusion = conclusion_wilcox
      ))
    }
  }
  
  # 6. Test de Anderson-Darling (normalidad multivariada)
  if (n_vars >= 2 && nrow(data) >= 8) {
    tryCatch({
      for (i in 1:n_vars) {
        ad_test <- ad.test(data[,i])
        conclusion_ad <- ifelse(ad_test$p.value < alpha, "No normal", "Normal")
        
        resultados <- rbind(resultados, data.frame(
          Test = paste("Anderson-Darling:", nombres_vars[i]),
          Estadistico = round(ad_test$statistic, 4),
          p_valor = round(ad_test$p.value, 6),
          Conclusion = conclusion_ad
        ))
      }
    }, error = function(e) {
      cat("Advertencia: No se pudo ejecutar el test de Anderson-Darling\n")
    })
  }
  
  # 7. Test de Levene (homogeneidad de varianzas)
  if (n_vars > 2) {
    tryCatch({
      library(car)
      data_long <- reshape2::melt(data.frame(data, row = 1:nrow(data)), 
                                 id.vars = "row", variable.name = "Variable", value.name = "Valor")
      levene_test <- leveneTest(Valor ~ Variable, data = data_long)
      conclusion_levene <- ifelse(levene_test$"Pr(>F)"[1] < alpha, "Varianzas diferentes", "Varianzas homogéneas")
      
      resultados <- rbind(resultados, data.frame(
        Test = "Levene (homogeneidad varianzas)",
        Estadistico = round(levene_test$"F value"[1], 4),
        p_valor = round(levene_test$"Pr(>F)"[1], 6),
        Conclusion = conclusion_levene
      ))
    }, error = function(e) {
      cat("Advertencia: No se pudo ejecutar el test de Levene (requiere paquete 'car')\n")
    })
  }
  
  # 8. ANOVA (si hay más de 2 variables)
  if (n_vars > 2) {
    data_long <- reshape2::melt(data.frame(data, row = 1:nrow(data)), 
                               id.vars = "row", variable.name = "Variable", value.name = "Valor")
    anova_test <- aov(Valor ~ Variable, data = data_long)
    anova_summary <- summary(anova_test)
    conclusion_anova <- ifelse(anova_summary[[1]][["Pr(>F)"]][1] < alpha, "Medias diferentes", "Medias similares")
    
    resultados <- rbind(resultados, data.frame(
      Test = "ANOVA (comparación medias)",
      Estadistico = round(anova_summary[[1]][["F value"]][1], 4),
      p_valor = round(anova_summary[[1]][["Pr(>F)"]][1], 6),
      Conclusion = conclusion_anova
    ))
  }
  
  # 9. Test de Kruskal-Wallis (no paramétrico)
  if (n_vars > 2) {
    data_long <- reshape2::melt(data.frame(data, row = 1:nrow(data)), 
                               id.vars = "row", variable.name = "Variable", value.name = "Valor")
    kw_test <- kruskal.test(Valor ~ Variable, data = data_long)
    conclusion_kw <- ifelse(kw_test$p.value < alpha, "Distribuciones diferentes", "Distribuciones similares")
    
    resultados <- rbind(resultados, data.frame(
      Test = "Kruskal-Wallis",
      Estadistico = round(kw_test$statistic, 4),
      p_valor = round(kw_test$p.value, 6),
      Conclusion = conclusion_kw
    ))
  }
  
  # Conclusión general
  tests_dependencia <- c("Dependientes", "Distribuciones diferentes", "Medianas diferentes", 
                        "No normal", "Varianzas diferentes", "Medias diferentes")
  prop_dependientes <- sum(resultados$Conclusion %in% tests_dependencia) / nrow(resultados)
  
  cat("\n")
  cat(paste(rep("=", 80), collapse = ""), "\n")
  cat("               TESTS DE INDEPENDENCIA PARA VARIABLES DE SEVERIDAD\n")
  cat(paste(rep("=", 80), collapse = ""), "\n")
  cat("Nivel de significancia:", alpha, "\n")
  cat("Variables analizadas:", paste(nombres_vars, collapse = ", "), "\n")
  cat("Número de observaciones:", nrow(data), "\n")
  cat(paste(rep("-", 80), collapse = ""), "\n")
  
  print(kable(resultados, format = "simple", digits = 6, align = c("l", "r", "r", "c")))
  
  cat("\n")
  cat(paste(rep("-", 80), collapse = ""), "\n")
  cat("CONCLUSIÓN GENERAL:\n")
  cat(paste(rep("-", 80), collapse = ""), "\n")
  
  if (prop_dependientes >= 0.7) {
    cat("EVIDENCIA FUERTE DE DEPENDENCIA/DIFERENCIAS entre las variables de severidad.\n")
    cat(sprintf("%.1f%% de los tests indican dependencia o diferencias significativas.\n", prop_dependientes * 100))
  } else if (prop_dependientes >= 0.3) {
    cat("EVIDENCIA MIXTA sobre la independencia de las variables de severidad.\n")
    cat(sprintf("%.1f%% de los tests indican dependencia o diferencias significativas.\n", prop_dependientes * 100))
    cat("Se recomienda análisis adicional.\n")
  } else {
    cat("EVIDENCIA DE INDEPENDENCIA entre las variables de severidad.\n")
    cat(sprintf("%.1f%% de los tests indican dependencia o diferencias significativas.\n", prop_dependientes * 100))
  }
  
  cat("\nNOTAS:\n")
  cat("- Pearson mide dependencia lineal\n")
  cat("- Spearman y Kendall miden dependencia monotónica\n")
  cat("- Kolmogorov-Smirnov compara distribuciones completas\n")
  cat("- Wilcoxon compara medianas (no paramétrico)\n")
  cat("- Anderson-Darling evalúa normalidad individual\n")
  cat("- Levene evalúa homogeneidad de varianzas\n")
  cat("- ANOVA compara medias (paramétrico)\n")
  cat("- Kruskal-Wallis compara distribuciones (no paramétrico)\n")
  cat(paste(rep("=", 80), collapse = ""), "\n")
  
  return(invisible(resultados))
}