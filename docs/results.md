# Results

## 1. Differential Gene Expression Analysis

Differential gene expression analysis was performed using two DESeq2 models: a primary model (`~ group`) and an adjusted model (`~ age_scaled + sex + group`).

Genes with an adjusted p-value (padj) below 0.1 were considered statistically significant.

| Analysis | Significant genes |
|---|---:|
| Primary model | 7,913 |
| Adjusted model | 4,809 |
| Significant in both models | 4,445 |

Among the 4,445 genes significant in both models, 4,444 showed concordant log2 fold-change directions.

Comparison of log2 fold-change directions across the two models showed:

- Consistent direction: 18,193 genes (76.73%)
- Opposite direction: 2,807 genes (11.84%)
- Missing estimates: 2,707 genes (11.42%)
- Zero direction: 3 genes (0.01%)

The adjusted model identified fewer significant genes than the primary model. This indicates that accounting for age and sex changed the statistical results.

However, genes significant in both models should be considered candidate genes for further investigation, rather than confirmed OA-specific genes.

## 2. Principal Component Analysis (PCA)

PCA was performed using variance-stabilized expression data and the 500 most variable genes.

The first two principal components explained:

| Component | Explained variance |
|---|---:|
| PC1 | 47.0% |
| PC2 | 15.6% |
| Combined | 62.6% |

The relationship between age and PC1 was examined using Spearman correlation.

- Spearman's rho: 0.601
- P-value: 0.00503

This indicated a positive association between age and PC1 in the analyzed samples.

An exploratory linear regression model was also fitted:

`PC1 ~ age + group + sex`

The estimated coefficients were:

| Variable | Coefficient | P-value |
|---|---:|---:|
| Age | -0.0040 | 0.9858 |
| Group (OA vs Normal) | +40.21 | 0.000033 |
| Sex (M vs F) | +3.47 | 0.5047 |

The overall model R-squared was 0.8143.

The group coefficient was statistically significant in this fitted model. However, this result should be interpreted cautiously because age and disease group were strongly associated in the dataset.

## 3. Age and Group Distribution

The age distribution differed substantially between the two groups.

| Statistic | Normal | OA |
|---|---:|---:|
| Sample size | 10 | 10 |
| Minimum age | 18 | 51 |
| Median age | 36.5 | 64.5 |
| Mean age | 39.7 | 62.7 |
| Maximum age | 61 | 71 |

The age ranges overlapped only between 51 and 61 years.

The Pearson correlation between age and OA group status was 0.739 (p = 0.000199).

These findings indicate substantial age imbalance and limited overlap between the groups. Consequently, it is difficult to distinguish the effects associated with OA from those associated with age.

## 4. Gene Ontology (GO) Enrichment Analysis

GO Biological Process enrichment analysis was performed separately for genes with concordant positive and negative log2 fold changes in the two DESeq2 models.

### 4.1 OA-Up Gene Set

A total of 2,164 genes were included before identifier conversion, corresponding to 1,982 mapped Entrez Gene IDs.

The analysis identified 86 enriched GO Biological Process terms.

Representative enriched terms included:

- Extracellular matrix organization
- Extracellular structure organization
- Collagen fibril organization
- Integrin-mediated signaling pathway
- Glycoprotein metabolic process
- Bone development

These results suggest that genes associated with extracellular matrix organization and remodeling were overrepresented among the OA-up candidates.

### 4.2 OA-Down Gene Set

A total of 2,280 genes were included before identifier conversion, corresponding to 2,009 mapped Entrez Gene IDs.

The analysis identified 105 enriched GO Biological Process terms.

Representative enriched terms included:

- Cytoplasmic translation
- RNA splicing
- mRNA processing
- Regulation of RNA splicing
- Ribonucleoprotein complex biogenesis
- mRNA transport

These results indicate overrepresentation of genes associated with RNA processing and translation-related biological processes among the OA-down candidates.

The enrichment analysis used a shared testable background of 21,003 gene symbols, of which 18,503 mapped to Entrez Gene IDs. The effective GO-annotated background was smaller because not all mapped genes had annotations for the analyzed ontology.

## 5. Cartilage-Related Gene Expression

Five cartilage-related genes were examined using normalized expression counts.

Four genes showed increased expression in OA samples and were statistically significant in the adjusted DESeq2 model.

| Gene | Adjusted log2FC | Adjusted padj | Approximate fold change |
|---|---:|---:|---:|
| MMP13 | +4.218 | 5.45 × 10⁻⁹ | 18.6 |
| ADAMTS5 | +2.903 | 1.95 × 10⁻⁶ | 7.5 |
| COL2A1 | +3.019 | 0.0193 | 8.1 |
| COMP | +1.200 | 0.0102 | 2.3 |
| ACAN | -0.015 | 0.9707 | 1.0 |

The approximate fold changes were calculated as \(2^{\text{log2FC}}\).

MMP13 and ADAMTS5, which encode enzymes associated with extracellular matrix degradation, showed increased estimated expression in OA samples.

COL2A1 and COMP, which encode cartilage-associated extracellular matrix proteins, also showed increased estimated expression.

In contrast, ACAN did not show a statistically significant expression difference in either model.

These findings suggest that OA cartilage may exhibit changes in both matrix-degrading enzymes and cartilage-associated matrix components.

**Figure:** `results/cartilage_marker_expression.png`

The figure displays normalized expression counts for all five genes across the Normal and OA samples.

## 6. Summary of Main Findings

The analysis identified several notable patterns:

1. Differential expression analysis identified thousands of statistically significant genes, with fewer genes remaining significant after adjustment for age and sex.
2. PCA showed substantial variation in gene expression associated with sample differences, and PC1 was positively correlated with age.
3. GO enrichment analysis highlighted extracellular matrix-related processes among OA-up candidates and RNA processing and translation-related processes among OA-down candidates.
4. MMP13, ADAMTS5, COL2A1, and COMP showed increased estimated expression in OA samples, while ACAN showed no statistically significant difference.

Overall, the findings suggest extensive gene expression differences between normal and OA cartilage. However, the strong age imbalance and small sample size mean that these results should be interpreted as exploratory associations rather than definitive evidence of OA-specific biological mechanisms.
