# Compare log2 fold changes between primary and adjusted analyses

# 1. Load DESeq2 results
primary <- read.csv("results/deseq2_primary_group.csv")
adjusted <- read.csv("results/deseq2_adjusted_age_sex.csv")

# 2. Select relevant columns
primary_selected <- primary[, c(
  "gene_symbol",
  "log2FoldChange",
  "pvalue",
  "padj"
)]

adjusted_selected <- adjusted[, c(
  "gene_symbol",
  "log2FoldChange",
  "pvalue",
  "padj"
)]

# 3. Rename columns
colnames(primary_selected)[-1] <- c(
  "log2FC_primary",
  "pvalue_primary",
  "padj_primary"
)

colnames(adjusted_selected)[-1] <- c(
  "log2FC_adjusted",
  "pvalue_adjusted",
  "padj_adjusted"
)

# 4. Merge results by gene symbol
comparison <- merge(
  primary_selected,
  adjusted_selected,
  by = "gene_symbol"
)

# 5. Calculate log2FC difference
comparison$log2FC_difference <-
  comparison$log2FC_adjusted - comparison$log2FC_primary

# 6. Identify statistical significance
comparison$primary_significant <-
  !is.na(comparison$padj_primary) &
  comparison$padj_primary < 0.1

comparison$adjusted_significant <-
  !is.na(comparison$padj_adjusted) &
  comparison$padj_adjusted < 0.1

# 7. Classify expression direction
comparison$direction_status <- ifelse(
  is.na(comparison$log2FC_primary) |
  is.na(comparison$log2FC_adjusted),
  "Missing",
  ifelse(
    comparison$log2FC_primary == 0 |
    comparison$log2FC_adjusted == 0,
    "Zero",
    ifelse(
      sign(comparison$log2FC_primary) ==
      sign(comparison$log2FC_adjusted),
      "Consistent",
      "Opposite"
    )
  )
)

# 8. Save complete comparison
write.csv(
  comparison,
  "results/log2fc_comparison.csv",
  row.names = FALSE
)

# 9. Print summary
cat("\n--- log2FC comparison ---\n")

cat("Total genes:", nrow(comparison), "\n\n")

cat("--- Direction classification ---\n")
print(table(comparison$direction_status))

cat("\n--- Statistical significance ---\n")

cat(
  "Primary significant:",
  sum(comparison$primary_significant),
  "\n"
)

cat(
  "Adjusted significant:",
  sum(comparison$adjusted_significant),
  "\n"
)

cat(
  "Significant in both:",
  sum(
    comparison$primary_significant &
    comparison$adjusted_significant
  ),
  "\n"
)

cat("\nComparison saved successfully.\n")
