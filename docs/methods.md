# Methods

## 1. Dataset and Sample Selection

This project analyzed gene expression differences between normal and osteoarthritis (OA) human articular cartilage.

The dataset was obtained from the NCBI Gene Expression Omnibus (GEO):

- **GEO accession:** GSE114007
- **Platform:** GPL18573
- **Groups:** Normal cartilage and OA cartilage
- **Final sample size:** 20 samples (10 Normal and 10 OA)

Samples were selected based on the GPL18573 platform to maintain platform consistency in the analysis.

The final expression count matrix contained 23,710 genes across 20 samples.

Sample metadata included:
- Group (Normal or OA)
- Age
- Sex

## 2. Data Preprocessing

Raw gene expression counts and sample metadata were prepared for downstream analysis.

The following checks were performed:

- Verification of sample identifiers between the expression matrix and metadata.
- Verification of gene identifiers and duplicate gene symbols.
- Verification that count values were non-negative integers.
- Confirmation that the final dataset contained 10 Normal and 10 OA samples.

The resulting count matrix was used as input for differential expression analysis with DESeq2.

## 3. Differential Gene Expression Analysis

Differential gene expression analysis was performed using the R package **DESeq2**.

Two statistical models were evaluated.

### 3.1 Primary Model

The primary model was:

`~ group`

This model compared OA cartilage with normal cartilage without adjusting for age or sex.

The contrast was specified as:

`OA vs Normal`

Therefore:
- Positive log2 fold change (log2FC): higher estimated expression in OA.
- Negative log2 fold change (log2FC): lower estimated expression in OA.

### 3.2 Adjusted Model

A second model was used to account for potential differences in age and sex:

`~ age_scaled + sex + group`

Age was standardized using R's `scale()` function before fitting the model.

This model estimated the association between group and gene expression while adjusting for age and sex.

### 3.3 Statistical Significance

Adjusted p-values (Benjamini-Hochberg correction) were used to assess statistical significance.

Genes with an adjusted p-value (padj) below 0.1 were considered statistically significant for the differential expression comparisons.

The results of the two models were compared to identify genes that remained significant across both analyses and to examine consistency in their estimated expression directions.

## 4. Principal Component Analysis (PCA)

Principal Component Analysis (PCA) was performed to explore variation in gene expression across samples.

Variance-stabilizing transformation (VST) was applied using DESeq2:

`vst(dds, blind = FALSE)`

The top 500 most variable genes were used for PCA visualization.

Samples were plotted according to:
- Group (Normal or OA)
- Sex

PCA coordinates were also examined in relation to age.

Spearman correlation and linear regression were used as exploratory approaches to investigate associations between age, group, sex, and the first principal component (PC1).

## 5. Gene Ontology (GO) Enrichment Analysis

Functional enrichment analysis was performed using the R package **clusterProfiler** and the annotation package **org.Hs.eg.db**.

The analysis focused on Gene Ontology Biological Process (GO BP) terms.

Genes with concordant expression directions in the primary and adjusted models were separated into two groups:

- OA-up: genes with positive log2FC in both models.
- OA-down: genes with negative log2FC in both models.

Gene symbols were converted to Entrez Gene IDs using `bitr()`.

The background universe consisted of genes with non-missing p-values in both differential expression models that could be mapped to the annotation database.

GO enrichment was performed using `enrichGO()` with:

- Ontology: Biological Process (BP)
- Multiple testing correction: Benjamini-Hochberg
- P-value cutoff: 0.05
- Q-value cutoff: 0.20

GO enrichment results were visualized using dot plots.

Because not all genes have GO annotations, the effective background used for individual enrichment calculations could be smaller than the total number of mapped background genes.

## 6. Cartilage-Related Gene Expression Visualization

Normalized expression counts from DESeq2 were used to visualize five cartilage-related genes:

- MMP13
- ADAMTS5
- COL2A1
- COMP
- ACAN

Boxplots and individual sample points were generated using **ggplot2**.

The expression values were displayed on a logarithmic (base 10) scale to facilitate visualization across different expression ranges.

These plots were used to compare expression patterns between Normal and OA samples.

## 7. Software and Tools

The analysis was performed using:

| Software / Package | Version |
|---|---|
| R | 4.5.2 |
| DESeq2 | 1.50.2 |
| Python | 3.14.4 |
| JupyterLab | 4.6.3 |
| clusterProfiler | Bioconductor package |
| org.Hs.eg.db | Bioconductor package |
| ggplot2 | R package |
| dplyr | R package |
| tidyr | R package |

The analysis environment was WSL Ubuntu on Windows 11.
