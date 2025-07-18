polizas_diarias <- function(polizas){
    
    fechas_2018 <- seq(as.Date("2018-01-01"), as.Date("2018-12-31"), by = "day")
    
    calcular_cobertura <- function(polizas, columna_cobertura) {
        polizas_cobertura <- polizas[polizas[[columna_cobertura]] == 1, ]
        
        resultado <- data.frame(
            Fecha = fechas_2018,
            Numero_polizas = 0,
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
                
                vigencias <- as.numeric(difftime(polizas_vigentes$Fecha_fin, fecha, units = "days")) + 1
                vigencias <- pmax(vigencias, 1)
                resultado$Exposicion[i] <- sum(as.numeric(vigencias))
            }
        }
        
        return(resultado)
    }
    
    PPD <- calcular_cobertura(polizas, "ppd")
    PTH <- calcular_cobertura(polizas, "pth")
    PPH <- calcular_cobertura(polizas, "pph")
    RC <- calcular_cobertura(polizas, "rc")
    
    return(list(PPD = PPD, PTH = PTH, PPH = PPH, RC = RC))
}

polizas_mensuales <- function(polizas){
    
    meses_2018 <- 1:12
    
    calcular_cobertura <- function(polizas, columna_cobertura) {
        polizas_cobertura <- polizas[polizas[[columna_cobertura]] == 1, ]
        
        resultado <- data.frame(
            Mes = meses_2018,
            Numero_polizas = 0
        )
        
        for (i in 1:nrow(resultado)) {
            mes <- resultado$Mes[i]
            fecha_inicio_mes <- as.Date(paste("2018", sprintf("%02d", mes), "01", sep = "-"))
            fecha_fin_mes <- as.Date(paste("2018", sprintf("%02d", mes), 
                                         ifelse(mes == 2, "28", 
                                                ifelse(mes %in% c(4, 6, 9, 11), "30", "31")), 
                                         sep = "-"))
            
            polizas_vigentes <- polizas_cobertura[
                polizas_cobertura$Fecha_inicio <= fecha_fin_mes & 
                polizas_cobertura$Fecha_fin >= fecha_inicio_mes, 
            ]
            
            if (nrow(polizas_vigentes) > 0) {
                resultado$Numero_polizas[i] <- nrow(polizas_vigentes)
            }
        }
        
        return(resultado)
    }
    
    PPD <- calcular_cobertura(polizas, "ppd")
    PTH <- calcular_cobertura(polizas, "pth")
    PPH <- calcular_cobertura(polizas, "pph")
    RC <- calcular_cobertura(polizas, "rc")
    
    return(list(PPD = PPD, PTH = PTH, PPH = PPH, RC = RC))
}