# 変形性膝関節症（OA）における軟骨遺伝子発現解析

## 1. プロジェクト概要

本プロジェクトでは、正常軟骨と変形性関節症（Osteoarthritis：OA）軟骨の遺伝子発現データ（公開データベース）を用いて、両群間の発現変動遺伝子および関連する生物学的プロセスを解析しました。

私自身が怪我を経験したことから、軟骨の損傷や変性、再生に関わる生物学的な仕組みに関心を持ち、その理解を深めるために本テーマを選択しました。

バイオインフォマティクスの解析工程：RおよびPythonによるデータ処理、統計解析、可視化を実践し、データから生物学的な特徴を読み取ること。
そして、分析結果を再利用可能な形で管理するとともに、データベース構築からクラウド移行、移行後のデータ整合性確認までの一連の工程を実践することを目的としています。



## 6. 使用技術・ツール

| 分類 | 使用技術 |
|---|---|
| プログラミング言語 | R、Python(前処理) |
| 統計解析 | DESeq2 |
| 機能解析 | clusterProfiler、org.Hs.eg.db |
| データ可視化 | ggplot2 |
| 開発環境 | WSL Ubuntu、JupyterLab |
| データソース | NCBI GEO |

## 7. ディレクトリ構成

```text
bioinformatics/
├── data/
│   ├── raw/
│   └── processed/
├── docs/
│   ├── analytics/
│   │   ├── methods.md
│   │   ├── results.md
│   │   ├── discussion.md
│   │   └── references.md
│   └── data_management/
│       ├── AWS構築・データ移行.md
│       ├── データベース設計.md
│       ├── 問題と改善方法.md
│       └── README.md
├── notebooks/
├── scripts/
├── results/
└── README.md
```

## 8. 詳細資料

各解析とデータ管理の詳細は、以下を参照してください。

[データ分析TOP（analytics）](docs/analytics/)
- [解析手法（methods）](docs/analytics/methods.md)
- [解析結果（Results）](docs/analytics/results.md)
- [考察・解析上の制約（Discussion）](docs/analytics/discussion.md)
- [参考文献（References）](docs/analytics/references.md)

[データ管理TOP（data_management）](docs/data_management/)
- [AWS構築・データ移行](docs/data_management/AWS構築・データ移行.md)
- [データベース設計](docs/data_management/データベース設計.md)
- [問題と改善方法](docs/data_management/問題と改善方法.md)

## 9. 今後の展望

今後はAWSを利用したクラウド環境の構築、データベースによるデータ管理などを追加し、解析からデータ管理まで一貫した実践的なポートフォリオへの発展を目指します。

---

**プロジェクト状況：初期解析および基本ドキュメント作成完了**
