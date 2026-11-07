# Compare primary and adjusted DESeq2 results

# 1. Load results
primary <- read.csv("results/deseq2_primary_group.csv")
adjusted <- read.csv("results/deseq2_adjusted_age_sex.csv")

# 2. Identify significant genes
primary_sig <- primary[
  !is.na(primary$padj) & primary$padj < 0.1,
]

adjusted_sig <- adjusted[
  !is.na(adjusted$padj) & adjusted$padj < 0.1,
]

# 3. Compare gene symbols
common_genes <- intersect(
  primary_sig$gene_symbol,
  adjusted_sig$gene_symbol
)

primary_only <- setdiff(
  primary_sig$gene_symbol,
  adjusted_sig$gene_symbol
)

adjusted_only <- setdiff(
  adjusted_sig$gene_symbol,
  primary_sig$gene_symbol
)

# 4. Print summary
cat("\n--- Differential expression comparison ---\n")

cat("Primary significant genes:", nrow(primary_sig), "\n")
cat("Adjusted significant genes:", nrow(adjusted_sig), "\n")

cat("Common significant genes:", length(common_genes), "\n")
cat("Primary-only significant genes:", length(primary_only), "\n")
cat("Adjusted-only significant genes:", length(adjusted_only), "\n")

# 5. Save gene lists
write.csv(
  data.frame(gene_symbol = common_genes),
  "results/common_significant_genes.csv",
  row.names = FALSE
)

write.csv(
  data.frame(gene_symbol = primary_only),
  "results/primary_only_significant_genes.csv",
  row.names = FALSE
)

write.csv(
  data.frame(gene_symbol = adjusted_only),
  "results/adjusted_only_significant_genes.csv",
  row.names = FALSE
)

cat("\nComparison completed. Gene lists saved in results/.\n")
