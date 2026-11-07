# ============================================================
# GO Biological Process enrichment analysis
# Dataset: GSE114007 (Normal vs OA cartilage)
# ============================================================

suppressPackageStartupMessages({
  library(clusterProfiler)
  library(org.Hs.eg.db)
  library(ggplot2)
})

# 1. Load input files
primary <- read.csv(
  "results/deseq2_primary_group.csv",
  check.names = FALSE
)

adjusted <- read.csv(
  "results/deseq2_adjusted_age_sex.csv",
  check.names = FALSE
)

candidates <- read.csv(
  "results/shared_concordant_genes.csv",
  check.names = FALSE
)

# 2. Define the background universe
# Include genes with non-missing p-values in BOTH models.
background_symbols <- intersect(
  primary$gene_symbol[!is.na(primary$pvalue)],
  adjusted$gene_symbol[!is.na(adjusted$pvalue)]
)

background_symbols <- unique(background_symbols)

# 3. Separate direction-concordant candidate genes
up_symbols <- unique(
  candidates$gene_symbol[
    candidates$log2FoldChange_primary > 0 &
    candidates$log2FoldChange_adjusted > 0
  ]
)

down_symbols <- unique(
  candidates$gene_symbol[
    candidates$log2FoldChange_primary < 0 &
    candidates$log2FoldChange_adjusted < 0
  ]
)

# 4. Map gene symbols to Entrez IDs
all_symbols <- unique(c(
  background_symbols,
  up_symbols,
  down_symbols
))

gene_mapping <- bitr(
  all_symbols,
  fromType = "SYMBOL",
  toType = "ENTREZID",
  OrgDb = org.Hs.eg.db
)

# Save the mapping table for reproducibility
write.csv(
  gene_mapping,
  "results/gene_symbol_to_entrez.csv",
  row.names = FALSE
)

# 5. Prepare unique Entrez ID lists
background_entrez <- unique(
  gene_mapping$ENTREZID[
    gene_mapping$SYMBOL %in% background_symbols
  ]
)

up_entrez <- unique(
  gene_mapping$ENTREZID[
    gene_mapping$SYMBOL %in% up_symbols
  ]
)

down_entrez <- unique(
  gene_mapping$ENTREZID[
    gene_mapping$SYMBOL %in% down_symbols
  ]
)

# Restrict candidate genes to the mapped background
up_entrez <- intersect(up_entrez, background_entrez)
down_entrez <- intersect(down_entrez, background_entrez)

# 6. Print analysis counts
cat("\n--- GO enrichment input summary ---\n")
cat("Background symbols:", length(background_symbols), "\n")
cat("Background Entrez IDs:", length(background_entrez), "\n")
cat("OA-up symbols:", length(up_symbols), "\n")
cat("OA-up Entrez IDs:", length(up_entrez), "\n")
cat("OA-down symbols:", length(down_symbols), "\n")
cat("OA-down Entrez IDs:", length(down_entrez), "\n")

# 7. Run GO Biological Process enrichment
run_go <- function(gene_ids, label) {

  if (length(gene_ids) == 0) {
    warning("No mapped genes available for: ", label)
    return(NULL)
  }

  enrichGO(
    gene          = gene_ids,
    universe      = background_entrez,
    OrgDb         = org.Hs.eg.db,
    keyType       = "ENTREZID",
    ont           = "BP",
    pAdjustMethod = "BH",
    pvalueCutoff  = 0.05,
    qvalueCutoff  = 0.20,
    readable      = TRUE
  )
}

go_up <- run_go(up_entrez, "OA-up")
go_down <- run_go(down_entrez, "OA-down")

# 8. Save enrichment tables and plots
save_go_results <- function(go_result, label) {

  if (is.null(go_result)) {
    return(invisible(NULL))
  }

  result_table <- as.data.frame(go_result)

  write.csv(
    result_table,
    paste0("results/go_", label, ".csv"),
    row.names = FALSE
  )

  if (nrow(result_table) > 0) {
    p <- dotplot(
      go_result,
      showCategory = min(20, nrow(result_table))
    ) +
      ggtitle(paste("GO Biological Process:", label))

    ggsave(
      filename = paste0("results/go_", label, "_dotplot.png"),
      plot = p,
      width = 10,
      height = 8,
      dpi = 300
    )
  } else {
    cat("No enriched GO terms found for", label, "\n")
  }
}

save_go_results(go_up, "OA_up")
save_go_results(go_down, "OA_down")

cat("\nGO enrichment analysis completed.\n")
