import pandas as pd
from pathlib import Path

# 入力ファイル
base_dir = Path("s3_upload/results")

pca_file = base_dir / "pca_coordinates.csv"
counts_file = base_dir / "deseq2_normalized_counts.csv"

# 出力先
output_dir = Path("data/processed/database")
output_dir.mkdir(parents=True, exist_ok=True)

# CSVを読み込む
pca = pd.read_csv(pca_file)
counts = pd.read_csv(counts_file)

# 必要な列が存在するか確認
required_pca = [
    "sample", "group", "age", "sex",
    "oa_grade", "platform", "sizeFactor", "PC1", "PC2"
]

for col in required_pca:
    if col not in pca.columns:
        raise ValueError(f"PCAデータに必要な列がありません: {col}")

if "gene_symbol" not in counts.columns:
    raise ValueError("発現量データに gene_symbol 列がありません")

# サンプル名の重複を確認
if pca["sample"].duplicated().any():
    raise ValueError("PCAデータに重複したsampleがあります")

# 遺伝子名の重複を確認
if counts["gene_symbol"].duplicated().any():
    raise ValueError("発現量データに重複したgene_symbolがあります")

# PCAデータと発現量データのサンプルが一致するか確認
sample_names = pca["sample"].tolist()
count_samples = [c for c in counts.columns if c != "gene_symbol"]

if set(sample_names) != set(count_samples):
    raise ValueError("PCAデータと発現量データのサンプルが一致しません")

# 1. サンプル情報テーブル
samples = pca[
    ["sample", "group", "age", "sex",
     "oa_grade", "platform", "sizeFactor"]
].copy()

# 2. PCA座標テーブル
pca_db = pca[["sample", "PC1", "PC2"]].copy()

# 3. 正規化発現量を縦長形式に変換
counts = counts[["gene_symbol"] + sample_names]

counts_long = counts.melt(
    id_vars="gene_symbol",
    var_name="sample",
    value_name="normalized_count"
)

# CSVを書き出す
samples.to_csv(output_dir / "samples.csv", index=False)
pca_db.to_csv(output_dir / "pca_coordinates_db.csv", index=False)
counts_long.to_csv(
    output_dir / "normalized_counts_long.csv",
    index=False
)

# 作成結果を検証
print("=== 作成結果 ===")
print(f"samples.csv: {len(samples)} rows")
print(f"pca_coordinates_db.csv: {len(pca_db)} rows")
print(f"normalized_counts_long.csv: {len(counts_long)} rows")

print("\n=== 欠損値の確認 ===")
print("samples:", samples.isna().sum().to_dict())
print("PCA:", pca_db.isna().sum().to_dict())
print("normalized counts:", counts_long.isna().sum().to_dict())

print("\n=== 発現量データの検証 ===")
print("遺伝子数:", counts_long["gene_symbol"].nunique())
print("サンプル数:", counts_long["sample"].nunique())
print("遺伝子×サンプル数:", len(counts_long))

expected_rows = len(counts) * len(sample_names)

if len(counts_long) != expected_rows:
    raise ValueError("縦長データの行数が期待値と一致しません")

if counts_long.isna().any().any():
    raise ValueError("加工後のデータに欠損値があります")

print("\nすべての検証に成功しました。")
print(f"出力先: {output_dir}")
