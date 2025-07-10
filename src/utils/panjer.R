panjer <- function(p, q, dist, params = c()){
    # Validar distribución primero
    if(!dist %in% c("poisson", "binomial negativa")){
        print("Distribucion de conteo no aceptada")
        return(NULL)
    }
    
    # Validar que se insertaron parámetros
    if(length(params) == 0){
        print("No se insertaron parametros")
        return(NULL)
    }
    
    # Validar y asignar parámetros según distribución
    if(dist == "poisson"){
        if(length(params) != 1){
            print("Poisson requiere exactamente 1 parametro (lambda)")
            return(NULL)
        }
        
        lambda <- params[1]
        if(lambda <= 0){
            print("Lambda debe ser positivo (> 0)")
            return(NULL)
        }
        
        a <- 0
        b <- lambda
        
        # Función generatriz de momentos para Poisson: M_N(t) = exp(λ(e^t - 1))
        m <- function(t) {
            return(exp(lambda * (exp(t) - 1)))
        }
    }
    
    if(dist == "binomial negativa"){
        if(length(params) != 2){
            print("Binomial negativa requiere exactamente 2 parametros (r, beta)")
            return(NULL)
        }
        
        r <- params[1]
        beta <- params[2]
        
        if(r != round(r) || r < 1){
            print("El parametro r debe ser un entero >= 1")
            return(NULL)
        }
        
        if(beta <= 0 || beta >= 1){
            print("El parametro beta debe estar en el intervalo (0, 1)")
            return(NULL)
        }
        
        a <- beta/(1 + beta)
        b <- (r - 1) * beta/(1 + beta)
        
        # Función generatriz de momentos para Binomial Negativa: M_N(t) = (1-β)^r / (1-β*e^t)^r
        m <- function(t) {
            return(((1 - beta)^r) / ((1 - beta * exp(t))^r))
        }
    }
    
    # Inicializar la recursión
    # f_S(0) = P(N=0) si P(X=0) = 0
    if(p[1] == 0){
        fs <- c(q[1])  # P(S=0) = P(N=0)
    } else {
        # Si P(X=0) > 0, usar función generatriz de momentos
        # f_S(0) = M_N(ln(p_0))
        fs <- c(m(log(p[1])))
    }
    
    # Algoritmo recursivo de Panjer
    s <- 1
    tolerancia_suma <- 0.9999  # Criterio: suma acumulada muy cercana a 1
    
    while(TRUE){
        # Calcular f_S(s) usando la recursión de Panjer
        suma <- 0
        
        for(k in 1:min(s, length(p)-1)){
            if(k+1 <= length(p) && s-k+1 <= length(fs)){
                suma <- suma + k * p[k+1] * fs[s-k+1]
            }
        }
        
        # Aplicar fórmula de Panjer: f_S(s) = (a + b/s) * suma
        fs_new <- (a + b/s) * suma
        
        # Agregar nueva probabilidad
        fs <- c(fs, fs_new)
        
        # Criterio de parada: suma acumulada muy cercana a 1
        suma_acumulada <- sum(fs)
        if(suma_acumulada >= tolerancia_suma){
            break
        }
        
        s <- s + 1
    }
    
    # Retornar resultados
    return(list(
        fs = fs,
        valores = 0:(length(fs)-1),
        parametros = list(a = a, b = b, dist = dist),
        iteraciones = s
    ))
}