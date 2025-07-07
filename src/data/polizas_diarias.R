polizas_diarias <- function(polizas){
    
    fechas_2018 <- seq(as.Date("2018-01-01"), as.Date("2018-12-31"), by = "day")
    
    calcular_cobertura <- function(polizas, columna_cobertura) {
        polizas_cobertura <- polizas[polizas[[columna_cobertura]] == 1, ]
        
        resultado <- data.frame(
            Fecha = fechas_2018,
            Numero_polizas = 0,
            Suma_primas = 0,
            Exposicion = 0
        )
        
        for (i in 1:nrow(resultado)) {
            fecha <- resultado$Fecha[i]
            
            polizas_vigentes <- polizas_cobertura[
                polizas_cobertura$Fecha_inicio <= fecha & 
                polizas_cobertura$Fecha_fin >= fecha, 
            ]
            
            if (nrow(polizas_vigentes) > 0) {
                resultado$Numero_polizas[i] <- nrow(polizas_vigentes)
                resultado$Suma_primas[i] <- sum(polizas_vigentes$Prima_ajustada)
                
                vigencias <- pmin(polizas_vigentes$Fecha_fin, as.Date("2018-12-31")) - fecha
                vigencias <- pmax(vigencias, 0)
                resultado$Exposicion[i] <- sum(as.numeric(vigencias)) / 365
            }
        }
        
        return(resultado)
    }
    
    PPD <- calcular_cobertura(polizas, "Perdida_parcial_danos")
    PTH <- calcular_cobertura(polizas, "Perdida_total_hurto")
    PPH <- calcular_cobertura(polizas, "Perdida_parcial_hurto")
    RC <- calcular_cobertura(polizas, "Responsabilidad_civil")
    
    return(list(PPD = PPD, PTH = PTH, PPH = PPH, RC = RC))
}