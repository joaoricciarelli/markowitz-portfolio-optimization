# markowitz-portfolio-optimization
Portfolio optimization in R using Modern Portfolio Theory

Exemplo didático de otimização de mínima volatilidade com quatro ativos fictícios, usando a Teoria Moderna do Portfólio de Harry Markowitz e o pacote Rsolnp.

O que o projeto faz
- Define retornos esperados, volatilidades e correlações hipotéticos para quatro ativos.
- Constrói a matriz de covariância a partir das volatilidades e correlações.
- Minimiza a volatilidade da carteira, impondo soma dos pesos igual a 100% e pesos entre 0% e 100% (sem venda a descoberto).
- Permite configurar um retorno esperado mínimo, caso desejado.
- Apresenta os pesos por ativo, valores monetários, retorno esperado, volatilidade e um gráfico de alocação.

Como executar
1. Instale o R e, opcionalmente, o RStudio.
2. No console do R, execute install.packages("Rsolnp") (uma única vez).
3. Abra markowitz_optimization.R e execute o script.
4. Para impor uma meta de retorno, altere retorno_minimo <- NULL para, por exemplo, retorno_minimo <- 0.10.
5. Ajuste investimento <- 1000000 para simular outro capital.

Formulação matemática
Se w é o vetor de pesos e Σ a matriz de covariância, o risco da carteira é:

σₚ = √(wᵀ Σ w)

O retorno esperado é E(Rₚ) = Σᵢ wᵢ E(Rᵢ).

O problema resolve minimizar σₚ, sujeito a Σᵢ wᵢ = 1, 0 ≤ wᵢ ≤ 1 e, opcionalmente, E(Rₚ) ≥ retorno mínimo.

Observações e limitações
- Todos os parâmetros são hipotéticos; não há conexão com dados de mercado nem validação fora da amostra.
- Os retornos e as volatilidades devem se referir à mesma periodicidade.
- Correlações históricas podem mudar; diversificação não elimina riscos.
- O código busca mínima volatilidade, não máximo retorno nem máximo índice de Sharpe. Sem retorno mínimo, encontra uma carteira de mínima variância global sob as restrições adotadas.
- Não considera custos de transação, impostos, liquidez, rebalanceamento ou incerteza de estimação.
- Os resultados são apenas ilustrativos e não constituem recomendação de investimento.

Arquivos
- markowitz_optimization.R — implementação comentada e gráfico simples.

Referências
- Markowitz, H. (1952). Portfolio Selection. The Journal of Finance, 7(1), 77–91.
- Rsolnp (documentação)

Licença
Escolha uma licença (por exemplo, MIT) ao publicar no GitHub, se quiser definir expressamente permissões de reutilização.
