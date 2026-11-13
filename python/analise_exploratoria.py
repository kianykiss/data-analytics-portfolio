import pandas as pd

# Base fictícia de vendas
dados = {
    "produto": ["A", "B", "C", "A"],
    "valor": [150, 200, 350, 100]
}

df = pd.DataFrame(dados)

# Análise de faturamento por produto
resultado = (
    df.groupby("produto", as_index=False)["valor"]
    .sum()
    .sort_values("valor", ascending=False)
)

print(resultado)
