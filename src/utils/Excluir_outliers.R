Excluir_outliers <- function(datos, threshold = 3.5, percentil_corte = 2.0, silencioso = FALSE) {
  
  datos <- as.numeric(na.omit(datos))
  datos_positivos <- datos[datos > 0]
  n_original <- length(datos)
  n_positivos <- length(datos_positivos)
  
  if (n_positivos < 5) {
    warning("Datos insuficientes para análisis robusto. Se retornan todos los datos positivos.")
    return(list(
      datos_limpios = datos_positivos,
      outliers = numeric(0),
      indices_outliers = integer(0),
      threshold_usado = threshold,
      percentil_usado = percentil_corte,
      estadisticas = list(
        n_original = n_original,
        n_positivos = n_positivos,
        n_outliers = 0,
        n_limpios = n_positivos,
        porcentaje_outliers = 0
      )
    ))
  }
  
  # Calcular percentiles para eliminación de extremos
  percentil_inf <- quantile(datos_positivos, percentil_corte/100, na.rm = TRUE)
  percentil_sup <- quantile(datos_positivos, 1 - percentil_corte/100, na.rm = TRUE)
  
  # Aplicar filtro de percentiles
  datos_percentil <- datos_positivos[datos_positivos >= percentil_inf & datos_positivos <= percentil_sup]
  outliers_percentil <- datos_positivos[datos_positivos < percentil_inf | datos_positivos > percentil_sup]
  
  mediana <- median(datos_percentil, na.rm = TRUE)
  mad_value <- mad(datos_percentil, na.rm = TRUE)
  
  if (mad_value == 0) {
    sd_backup <- sd(datos_percentil)
    if (sd_backup == 0) {
      warning("Datos completamente uniformes después del filtro de percentiles. Se retornan datos filtrados por percentiles.")
      return(list(
        datos_limpios = datos_percentil,
        outliers = outliers_percentil,
        indices_outliers = which(datos %in% outliers_percentil),
        threshold_usado = threshold,
        percentil_usado = percentil_corte,
        metodo_usado = "Solo percentiles"
      ))
    }
    mad_value <- sd_backup / 1.4826
  }
  
  # Aplicar Z-score robusto sobre datos ya filtrados por percentiles
  z_scores_filtrados <- abs((datos_percentil - mediana) / mad_value)
  
  datos_limpios <- datos_percentil[z_scores_filtrados <= threshold]
  outliers_zscore <- datos_percentil[z_scores_filtrados > threshold]
  
  # Combinar outliers de ambos métodos
  outliers_totales <- c(outliers_percentil, outliers_zscore)
  
  indices_originales <- which(datos > 0)
  indices_outliers <- indices_originales[datos_positivos %in% outliers_totales]
  
  n_outliers <- length(outliers_totales)
  n_limpios <- length(datos_limpios)
  porcentaje_outliers <- (n_outliers / n_positivos) * 100
  
  if (!silencioso) {
    cat("═══════════════════════════════════════════════════════════════════════════\n")
    cat("                    DETECCIÓN DE OUTLIERS - MÉTODO COMBINADO                \n")
    cat("═══════════════════════════════════════════════════════════════════════════\n")
    cat(sprintf("Datos originales: %d | Datos positivos: %d\n", n_original, n_positivos))
    cat(sprintf("Método 1 - Percentiles: %.1f%% cada extremo (%.2f - %.2f)\n", 
                percentil_corte, percentil_inf, percentil_sup))
    cat(sprintf("Método 2 - Z-score robusto: Threshold %.1f | Mediana: %.2f | MAD: %.4f\n", 
                threshold, mediana, mad_value))
    cat("───────────────────────────────────────────────────────────────────────────\n")
    cat(sprintf("Outliers por percentiles: %d (%.1f%%)\n", 
                length(outliers_percentil), (length(outliers_percentil)/n_positivos)*100))
    cat(sprintf("Outliers por Z-score: %d (%.1f%%)\n", 
                length(outliers_zscore), (length(outliers_zscore)/length(datos_percentil))*100))
    cat(sprintf("Outliers totales: %d (%.1f%%)\n", n_outliers, porcentaje_outliers))
    cat(sprintf("Datos limpios: %d (%.1f%%)\n", n_limpios, (n_limpios/n_positivos)*100))
    
    if (n_outliers > 0) {
      cat("───────────────────────────────────────────────────────────────────────────\n")
      cat("ESTADÍSTICAS DE OUTLIERS:\n")
      cat(sprintf("Rango outliers: [%.2f, %.2f]\n", min(outliers_totales), max(outliers_totales)))
      cat(sprintf("Media outliers: %.2f | Mediana outliers: %.2f\n", 
                  mean(outliers_totales), median(outliers_totales)))
      
      if (length(outliers_zscore) > 0) {
        cat(sprintf("Z-score máximo: %.2f | Z-score mínimo: %.2f\n", 
                    max(z_scores_filtrados[z_scores_filtrados > threshold]), 
                    min(z_scores_filtrados[z_scores_filtrados > threshold])))
      }
      
      cat("\nESTADÍSTICAS DE DATOS LIMPIOS:\n")
      cat(sprintf("Rango limpios: [%.2f, %.2f]\n", min(datos_limpios), max(datos_limpios)))
      cat(sprintf("Media limpios: %.2f | Mediana limpios: %.2f\n", 
                  mean(datos_limpios), median(datos_limpios)))
      
      if (length(outliers_zscore) == 0) {
        cat(sprintf("Z-score máximo limpios: %.2f\n", max(z_scores_filtrados)))
      } else {
        cat(sprintf("Z-score máximo limpios: %.2f\n", max(z_scores_filtrados[z_scores_filtrados <= threshold])))
      }
      
      if (n_outliers <= 20) {
        outliers_ordenados <- sort(outliers_totales)
        cat(sprintf("\nOUTLIERS DETECTADOS: %s\n", 
                    paste(round(outliers_ordenados, 2), collapse = ", ")))
      } else {
        outliers_ordenados <- sort(outliers_totales)
        cat(sprintf("\nPRIMEROS 10 OUTLIERS: %s...\n", 
                    paste(round(outliers_ordenados[1:10], 2), collapse = ", ")))
        cat(sprintf("ÚLTIMOS 10 OUTLIERS: %s\n", 
                    paste(round(tail(outliers_ordenados, 10), 2), collapse = ", ")))
      }
    }
    
    cat("───────────────────────────────────────────────────────────────────────────\n")
    cat("ESTADÍSTICAS ROBUSTAS:\n")
    cat(sprintf("Media tradicional: %.2f | Mediana robusta: %.2f\n", 
                mean(datos_positivos), mediana))
    cat(sprintf("SD tradicional: %.2f | MAD robusto: %.4f\n", 
                sd(datos_positivos), mad_value))
    cat(sprintf("Ratio SD/MAD: %.2f (>1.5 indica presencia de outliers)\n", 
                sd(datos_positivos) / mad_value))
    
    cat("═══════════════════════════════════════════════════════════════════════════\n")
  }
  
  resultado <- list(
    datos_limpios = datos_limpios,
    outliers = outliers_totales,
    outliers_percentil = outliers_percentil,
    outliers_zscore = outliers_zscore,
    indices_outliers = indices_outliers,
    z_scores = z_scores_filtrados,
    threshold_usado = threshold,
    percentil_usado = percentil_corte,
    percentiles_usados = list(
      inferior = percentil_inf,
      superior = percentil_sup
    ),
    parametros_robustos = list(
      mediana = mediana,
      mad = mad_value,
      media_tradicional = mean(datos_positivos),
      sd_tradicional = sd(datos_positivos),
      ratio_sd_mad = sd(datos_positivos) / mad_value
    ),
    estadisticas = list(
      n_original = n_original,
      n_positivos = n_positivos,
      n_outliers = n_outliers,
      n_outliers_percentil = length(outliers_percentil),
      n_outliers_zscore = length(outliers_zscore),
      n_limpios = n_limpios,
      porcentaje_outliers = porcentaje_outliers
    )
  )
  
  invisible(resultado)
}