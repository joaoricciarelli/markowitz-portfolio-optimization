
# ================================================================
# OTIMIZACAO DE CARTEIRA - TEORIA MODERNA DO PORTFOLIO (MARKOWITZ)
# ================================================================
# COMO UTILIZAR:
# 1. Altere os parametros na secao CONFIGURACOES DO USUARIO.
# 2. Execute o codigo completo no RStudio.
# 3. Analise os resultados e o grafico gerado.
#
# IMPORTANTE: dados ilustrativos; nao representam recomendacao
# financeira. Todos os retornos e desvios devem se referir ao
# mesmo horizonte temporal (por exemplo, anual).
#
# ================================================================


# ================================================================
# 1. CONFIGURACOES DO USUARIO
# ================================================================
# Altere os parametros abaixo para personalizar sua carteira.
# Nenhuma modificacao nas funcoes matematicas e necessaria.
# ================================================================


# 1.1 ATIVOS ------------------------------------------------------
# Identificacao dos ativos que compoem a carteira.
#
# Para adicionar ou remover ativos, ajuste tambem os vetores
# de retornos, volatilidades e a matriz de correlacoes.

ativos <- c("A", "B", "C", "D")


# 1.2 RETORNOS ESPERADOS ------------------------------------------
# Retorno esperado de cada ativo no periodo analisado.
#
# Exemplo:
# 0.10 = 10%
# 0.12 = 12%
#
# A ordem e a quantidade devem corresponder aos ativos acima.

retornos <- c(A=0.10 ,B=0.12, C=0.13, D=0.09)

names(retornos) <- ativos


# 1.3 VOLATILIDADES -----------------------------------------------
# Desvio-padrao dos retornos de cada ativo.
# Representa o risco individual de cada investimento.
#
# Exemplo:
# 0.22 = 22% de volatilidade
# 0.28 = 28% de volatilidade
#
# Deve utilizar o mesmo horizonte temporal dos retornos.

volatilidades <- c(A=0.22, B=0.28, C=0.32, D=0.18)

names(volatilidades) <- ativos


# 1.4 MATRIZ DE CORRELACAO ----------------------------------------
# Representa a relacao entre os retornos dos ativos.
#
# Valores possiveis:
# +1 = correlacao positiva perfeita
#  0 = ausencia de correlacao linear
# -1 = correlacao negativa perfeita
#
# A matriz deve ser simetrica, possuir diagonal igual a 1
# e ser semidefinida positiva.
#
# Exemplo:
# Correlacao entre A e B = -0.8
# Correlacao entre A e C =  0.3
# Correlacao entre A e D = -0.5
#
# Se alterar a quantidade de ativos, ajuste a matriz.

correlacoes <- matrix(c(
  1.0, -0.8,  0.3, -0.5, 
  -0.8,  1.0, -0.4,  0.7,
  0.3, -0.4,  1.0, -0.5,
  -0.5,  0.7, -0.5,  1.0
), nrow = length(ativos), byrow = TRUE,
dimnames = list(ativos, ativos))


# 1.5 INVESTIMENTO TOTAL ------------------------------------------
# Capital total disponivel para investir, em reais.
#
# Exemplo:
# 1000000 = R$ 1.000.000
# 50000   = R$ 50.000
#
# O valor modifica os montantes por ativo, mas nao os pesos
# percentuais da carteira otimizada.

investimento <- 1000000


# 1.6 RETORNO MINIMO ----------------------------------------------
# Retorno minimo esperado exigido para a carteira.
#
# NULL = carteira de minima volatilidade global, sem
#        exigencia de retorno minimo.
#
# 0.10 = exige pelo menos 10% de retorno esperado.
# 0.12 = exige pelo menos 12% de retorno esperado.
#
# A meta deve ser viavel considerando os retornos dos ativos
# e os limites de alocacao definidos.

retorno_minimo <- NULL


# 1.7 LIMITES DE ALOCACAO -----------------------------------------
# Percentual minimo e maximo permitido em cada ativo.
#
# 0 = 0%
# 1 = 100%
#
# Padrao:
# De 0% a 100% por ativo, sem vendas a descoberto.
#
# Exemplo de limite maximo de 50% para cada ativo:
# limite_superior <- rep(0.50, length(ativos))
#
# Tambem e possivel estabelecer limites diferentes:
# limite_inferior <- c(0, 0, 0, 0)
# limite_superior <- c(0.40, 0.50, 0.60, 0.30)

limite_inferior <- rep(0, length(ativos))
limite_superior <- rep(1, length(ativos))


# 1.8 PESOS INICIAIS ----------------------------------------------
# Distribuicao inicial utilizada pelo algoritmo de otimizacao.
#
# Padrao: alocacao igualitaria entre todos os ativos.
#
# Exemplo com quatro ativos:
# 0.25 = 25% em cada ativo.
#
# O ponto inicial pode influenciar o processo numerico,
# mas nao altera a formulacao matematica do problema.

pesos_iniciais <- rep(1 / length(ativos), length(ativos))


# ================================================================
# 2. DEPENDENCIA
# ================================================================
# Instale uma unica vez, se necessario:
# install.packages("Rsolnp")

library(Rsolnp)


# ================================================================
# 3. VALIDACAO DOS DADOS
# ================================================================

# Verifica se os vetores possuem o mesmo numero de ativos.
stopifnot(
  length(retornos) == length(ativos),
  length(volatilidades) == length(ativos),
  length(limite_inferior) == length(ativos),
  length(limite_superior) == length(ativos),
  length(pesos_iniciais) == length(ativos)
)

# Verifica se a matriz de correlacao possui as dimensoes corretas.
stopifnot(
  all(dim(correlacoes) == c(length(ativos), length(ativos)))
)

# Uma matriz de correlacoes valida deve ser semidefinida positiva.
# Esta verificacao e importante caso os valores sejam alterados.
stopifnot(
  isTRUE(all.equal(correlacoes, t(correlacoes))),
  all(abs(diag(correlacoes) - 1) < 1e-10),
  min(eigen(correlacoes, symmetric = TRUE,
            only.values = TRUE)$values) >= -1e-10
)

# Verifica a viabilidade dos limites de alocacao.
stopifnot(
  all(limite_inferior >= 0),
  all(limite_superior <= 1),
  all(limite_inferior <= limite_superior),
  sum(limite_inferior) <= 1,
  sum(limite_superior) >= 1
)

# Verifica o ponto inicial.
stopifnot(
  abs(sum(pesos_iniciais) - 1) < 1e-10,
  all(pesos_iniciais >= limite_inferior),
  all(pesos_iniciais <= limite_superior)
)


# ================================================================
# 4. MATRIZ DE COVARIANCIA
# ================================================================

# Cov(i,j) = Corr(i,j) * Desvio(i) * Desvio(j).
#
# A matriz de covariancia incorpora riscos individuais e
# correlacoes entre os ativos.

matriz_cov <- diag(as.numeric(volatilidades)) %*%
  correlacoes %*% diag(as.numeric(volatilidades))

dimnames(matriz_cov) <- list(ativos, ativos)


# ================================================================
# 5. FUNCOES DA CARTEIRA
# ================================================================

# Retorno esperado ponderado:
# E(Rp) = soma(w_i * E(R_i)).

retorno_carteira <- function(pesos) {
  sum(pesos * retornos)
}

# Risco (volatilidade):
# sigma_p = sqrt(w' * Sigma * w).
#
# As covariancias captam o beneficio potencial da diversificacao.

risco_carteira <- function(pesos) {
  sqrt(max(0, as.numeric(t(pesos) %*% matriz_cov %*% pesos)))
}

# Todos os recursos devem estar alocados.
# A soma dos pesos deve ser igual a 1 (100%).

restricao_total <- function(pesos) {
  sum(pesos)
}


# ================================================================
# 6. OTIMIZACAO DA CARTEIRA
# ================================================================

# Argumentos comuns ao otimizador SOLNP.

argumentos <- list(
  pars = pesos_iniciais,
  fun = risco_carteira,       # Minimizar volatilidade.
  eqfun = restricao_total,    # Soma dos pesos.
  eqB = 1,                   # Exatamente 100%.
  LB = limite_inferior,      # Limites minimos por ativo.
  UB = limite_superior,      # Limites maximos por ativo.
  control = list(trace = 0)
)

# Restricao opcional de retorno minimo.
#
# Quando retorno_minimo = NULL, o algoritmo calcula
# a carteira de minima volatilidade global.
#
# Quando definido, exige retorno esperado >= retorno_minimo.

if (!is.null(retorno_minimo)) {
  
  stopifnot(
    retorno_minimo >= min(retornos),
    retorno_minimo <= max(retornos)
  )
  
  argumentos$ineqfun <- retorno_carteira
  argumentos$ineqLB <- retorno_minimo
  argumentos$ineqUB <- max(retornos)
}

# Executa a otimizacao numerica (algoritmo SOLNP).

resultado <- do.call(Rsolnp::solnp, argumentos)


# ================================================================
# 7. RESULTADOS
# ================================================================

# Convergencia igual a zero indica que o solver convergiu.

if (resultado$convergence != 0) {
  warning("O solver nao reportou convergencia. Verifique a solucao.")
}

# Pesos otimizados e indicadores da carteira.

pesos_otimos <- setNames(as.numeric(resultado$pars), ativos)

retorno_otimo <- retorno_carteira(pesos_otimos)
risco_otimo <- risco_carteira(pesos_otimos)

valor_por_ativo <- investimento * pesos_otimos


# Tabela com pesos relativos e valores a investir.

tabela <- data.frame(
  Ativo = ativos,
  Peso_percentual = round(100 * pesos_otimos, 2),
  Valor_investido_R = round(valor_por_ativo, 2),
  row.names = NULL,
  check.names = FALSE
)


# Exibicao dos resultados no console.

cat("\n=== CARTEIRA OTIMIZADA ===\n")

print(tabela)

cat(sprintf("\nSoma dos pesos: %.4f\n", sum(pesos_otimos)))
cat(sprintf("Retorno esperado: %.2f%%\n", 100 * retorno_otimo))
cat(sprintf("Volatilidade: %.2f%%\n", 100 * risco_otimo))
cat(sprintf("Investimento total: R$ %.2f\n", investimento))
cat(sprintf("Convergencia (0 = sim): %s\n",
            resultado$convergence))

# Tempo de execucao do algoritmo.
print(resultado$elapsed)


# ================================================================
# 8. GRAFICO DE ALOCACAO
# ================================================================

# Grafico simples em R base, sem dependencias adicionais.
# Representa o percentual destinado a cada ativo.

barplot(
  100 * pesos_otimos,
  names.arg = ativos,
  main = "Alocacao da carteira de minima volatilidade",
  xlab = "Ativo",
  ylab = "Peso na carteira (%)",
  ylim = c(0, max(100 * pesos_otimos) * 1.15)
)

