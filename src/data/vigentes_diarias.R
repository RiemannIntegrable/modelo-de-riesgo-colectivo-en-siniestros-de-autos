vigentes_diarias <- function(df) {
  
  df <- na.omit(df[, c("inicio", "fin")])
  
  if (nrow(df) == 0) {
    stop("El dataframe no contiene datos válidos o las columnas 'inicio' y 'fin' no existen")
  }
  
  if (!inherits(df$inicio, "Date")) {
    df$inicio <- as.Date(df$inicio)
  }
  if (!inherits(df$fin, "Date")) {
    df$fin <- as.Date(df$fin)
  }
  
  fecha_min <- min(df$inicio, na.rm = TRUE)
  fecha_max <- max(df$fin, na.rm = TRUE)
  
  secuencia_fechas <- seq(from = fecha_min, to = fecha_max, by = "day")
  
  resultado <- data.frame(
    fecha = secuencia_fechas,
    polizas_activas = 0,
    stringsAsFactors = FALSE
  )
  
  for (i in 1:length(secuencia_fechas)) {
    fecha_actual <- secuencia_fechas[i]
    
    polizas_vigentes <- sum(df$inicio <= fecha_actual & df$fin >= fecha_actual, na.rm = TRUE)
    
    resultado$polizas_activas[i] <- polizas_vigentes
  }
  
  return(resultado)
}