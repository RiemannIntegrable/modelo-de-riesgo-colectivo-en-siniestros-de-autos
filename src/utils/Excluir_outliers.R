Excluir_outliers <- function(datos, threshold = 3.5, silencioso = FALSE) {
  
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
      estadisticas = list(
        n_original = n_original,
        n_positivos = n_positivos,
        n_outliers = 0,
        n_limpios = n_positivos,
        porcentaje_outliers = 0
      )
    ))
  }
  
  mediana <- median(datos_positivos, na.rm = TRUE)
  mad_value <- mad(datos_positivos, na.rm = TRUE)
  
  if (mad_value == 0) {
    sd_backup <- sd(datos_positivos)
    if (sd_backup == 0) {
      warning("Datos completamente uniformes. Se retornan todos los datos.")
      return(list(
        datos_limpios = datos_positivos,
        outliers = numeric(0),
        indices_outliers = integer(0),
        threshold_usado = threshold
      ))
    }
    mad_value <- sd_backup / 1.4826
  }
  
  z_scores <- abs((datos_positivos - mediana) / mad_value)
  
  datos_limpios <- datos_positivos[z_scores <= threshold]
  outliers <- datos_positivos[z_scores > threshold]
  
  indices_originales <- which(datos > 0)
  indices_outliers <- indices_originales[z_scores > threshold]
  
  n_outliers <- length(outliers)
  n_limpios <- length(datos_limpios)
  porcentaje_outliers <- (n_outliers / n_positivos) * 100
  
  if (!silencioso) {
    cat("═══════════════════════════════════════════════════════════════════════════\n")
    cat("                        DETECCIÓN DE OUTLIERS - Z-SCORE ROBUSTO             \n")
    cat("═══════════════════════════════════════════════════════════════════════════\n")
    cat(sprintf("Datos originales: %d | Datos positivos: %d | Threshold: %.1f\n", 
                n_original, n_positivos, threshold))
    cat(sprintf("Mediana: %.2f | MAD: %.4f\n", mediana, mad_value))
    cat("───────────────────────────────────────────────────────────────────────────\n")
    cat(sprintf("Outliers detectados: %d (%.1f%%)\n", n_outliers, porcentaje_outliers))
    cat(sprintf("Datos limpios: %d (%.1f%%)\n", n_limpios, (n_limpios/n_positivos)*100))
    
    if (n_outliers > 0) {
      cat("───────────────────────────────────────────────────────────────────────────\n")
      cat("ESTADÍSTICAS DE OUTLIERS:\n")
      cat(sprintf("Rango outliers: [%.2f, %.2f]\n", min(outliers), max(outliers)))
      cat(sprintf("Media outliers: %.2f | Mediana outliers: %.2f\n", 
                  mean(outliers), median(outliers)))
      cat(sprintf("Z-score máximo: %.2f | Z-score mínimo: %.2f\n", 
                  max(z_scores[z_scores > threshold]), min(z_scores[z_scores > threshold])))
      
      cat("\nESTADÍSTICAS DE DATOS LIMPIOS:\n")
      cat(sprintf("Rango limpios: [%.2f, %.2f]\n", min(datos_limpios), max(datos_limpios)))
      cat(sprintf("Media limpios: %.2f | Mediana limpios: %.2f\n", 
                  mean(datos_limpios), median(datos_limpios)))
      cat(sprintf("Z-score máximo limpios: %.2f\n", max(z_scores[z_scores <= threshold])))
      
      if (n_outliers <= 20) {
        outliers_ordenados <- sort(outliers)
        z_outliers <- z_scores[z_scores > threshold]
        z_ordenados <- z_outliers[order(outliers)]
        
        cat(sprintf("\nOUTLIERS DETECTADOS: %s\n", 
                    paste(paste0(round(outliers_ordenados, 2), " (z=", round(z_ordenados, 2), ")"), collapse = ", ")))
      } else {
        outliers_ordenados <- sort(outliers)
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
    outliers = outliers,
    indices_outliers = indices_outliers,
    z_scores = z_scores,
    threshold_usado = threshold,
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
      n_limpios = n_limpios,
      porcentaje_outliers = porcentaje_outliers
    )
  )
  
  invisible(resultado)
}