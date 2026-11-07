# GSE114007 データセットの説明

## 1. データセット情報

- データベース：NCBI Gene Expression Omnibus (GEO)
- アクセッション番号：GSE114007
- 研究名：Identification of transcription factors responsible for dysregulated networks in human osteoarthritis cartilage by global gene expression analysis
- 生物種：Homo sapiens
- データ種別：RNA-seq
- 組織：関節軟骨
- ゲノムビルド：hg19

データ取得元：
https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE114007

## 2. 元データ

GEOから取得した元データは以下のとおり。

- GSE114007_raw_counts.xlsx

元のExcelファイルには、NormalおよびOAの2つのワークシートが含まれる。

| グループ | 遺伝子数 | サンプル数 |
|---|---:|---:|
| Normal | 23,710 | 18 |
| OA | 23,710 | 20 |

元データのCSV出力について、Excelの各ワークシートとの一致を確認済み。

## 3. 解析対象データ

プラットフォームGPL18573のサンプルを選択し、以下の20サンプルを解析対象とした。

| グループ | サンプル数 |
|---|---:|
| Normal | 10 |
| OA | 10 |
| 合計 | 20 |

最終解析用カウント行列は23,710遺伝子、20サンプルで構成される。

## 4. データ検証

以下の項目を確認した。

- 遺伝子シンボルの欠損および重複がないこと
- カウント値が非負の整数であること
- カウント行列とメタデータのサンプルIDが一致すること
- サンプル数がNormal 10、OA 10であること
- 元データと抽出データのサンプル値が一致すること

## 5. 解析用ファイル

主な解析入力ファイルは以下のとおり。

- `processed/counts_GPL18573_raw.csv`
- `processed/metadata_deseq2.csv`

これらを使用してDESeq2による発現変動解析およびPCAを実施した。

## 6. 解析上の補足

元の研究ではlimma-voomが使用されているが、本プロジェクトではDESeq2を用いて独立した再解析を実施した。

また、年齢および性別を考慮したモデルも評価した。

Normal群とOA群の年齢分布には大きな偏りがあるため、解析結果は探索的な関連として解釈する必要がある。
