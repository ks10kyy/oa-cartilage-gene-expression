# Compare DESeq2 results from the primary and adjusted models

# Read the two DESeq2 result files
primary <- read.csv("results/deseq2_primary_group.csv")
adjusted <- read.csv("results/deseq2_adjusted_age_sex.csv")

# Match genes by gene symbol
combined <- merge(
  primary,
  adjusted,
  by = "gene_symbol",
  suffixes = c("_primary", "_adjusted")
)

# Select genes significant in both models
shared_significant <- subset(
  combined,
  !is.na(padj_primary) &
  !is.na(padj_adjusted) &
  padj_primary < 0.1 &
  padj_adjusted < 0.1
)

# Select genes with the same direction of change in both models
direction_concordant <- subset(
  shared_significant,
  sign(log2FoldChange_primary) ==
  sign(log2FoldChange_adjusted) &
  log2FoldChange_primary != 0 &
  log2FoldChange_adjusted != 0
)

# Sort by adjusted-model adjusted p-value
direction_concordant <- direction_concordant[
  order(direction_concordant$padj_adjusted),
]

# Save the results
write.csv(
  shared_significant,
  "results/shared_significant_genes.csv",
  row.names = FALSE
)

write.csv(
  direction_concordant,
  "results/shared_concordant_genes.csv",
  row.names = FALSE
)

# Display summary information
cat("Genes present in both result files:", nrow(combined), "\n")
cat("Significant in both models:", nrow(shared_significant), "\n")
cat("Significant with concordant direction:", nrow(direction_concordant), "\n")

cat("\nFirst 10 concordant candidate genes:\n")
print(
  head(
    direction_concordant[
      c(
        "gene_symbol",
        "log2FoldChange_primary",
        "padj_primary",
        "log2FoldChange_adjusted",
        "padj_adjusted"
      )
    ],
    10
  )
)
