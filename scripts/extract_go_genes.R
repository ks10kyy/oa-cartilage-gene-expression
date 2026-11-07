# ============================================================
# Extract genes associated with the top 10 GO terms
# ============================================================

# 1. Load GO enrichment results
go_files <- c(
  OA_up = "results/go_OA_up.csv",
  OA_down = "results/go_OA_down.csv"
)

# 2. Load candidate genes and their fold changes
candidates <- read.csv(
  "results/shared_concordant_genes.csv",
  check.names = FALSE
)

# 3. Extract genes from the top 10 GO terms
extract_genes <- function(file, direction) {

  go <- read.csv(file, check.names = FALSE)

  if (nrow(go) == 0) {
    warning("No GO terms found for ", direction)
    return(NULL)
  }

  # Sort by adjusted p-value
  go <- go[order(go$p.adjust), ]

  # Select the top 10 terms
  top_go <- head(go, 10)

  # Split slash-separated gene symbols into individual rows
  result <- do.call(
    rbind,
    lapply(seq_len(nrow(top_go)), function(i) {

      genes <- strsplit(
        top_go$geneID[i],
        "/",
        fixed = TRUE
      )[[1]]

      data.frame(
        direction = direction,
        GO_ID = top_go$ID[i],
        Description = top_go$Description[i],
        adjusted_p_value = top_go$p.adjust[i],
        gene_symbol = genes,
        stringsAsFactors = FALSE
      )
    })
  )

  result
}

# 4. Extract OA-up and OA-down genes
up_genes <- extract_genes(go_files["OA_up"], "OA_up")
down_genes <- extract_genes(go_files["OA_down"], "OA_down")

go_gene_table <- rbind(up_genes, down_genes)

# 5. Add DESeq2 fold-change information
go_gene_table <- merge(
  go_gene_table,
  candidates[, c(
    "gene_symbol",
    "log2FoldChange_primary",
    "log2FoldChange_adjusted",
    "padj_primary",
    "padj_adjusted"
  )],
  by = "gene_symbol",
  all.x = TRUE
)

# 6. Save detailed results
go_gene_table <- go_gene_table[
  order(go_gene_table$direction,
        go_gene_table$adjusted_p_value),
]

write.csv(
  go_gene_table,
  "results/go_top10_term_genes.csv",
  row.names = FALSE
)

# 7. Save unique gene lists by direction
up_unique <- unique(go_gene_table$gene_symbol[
  go_gene_table$direction == "OA_up"
])

down_unique <- unique(go_gene_table$gene_symbol[
  go_gene_table$direction == "OA_down"
])

write.csv(
  data.frame(gene_symbol = up_unique),
  "results/go_OA_up_unique_genes.csv",
  row.names = FALSE
)

write.csv(
  data.frame(gene_symbol = down_unique),
  "results/go_OA_down_unique_genes.csv",
  row.names = FALSE
)

# 8. Print summary
cat("\n--- Extraction summary ---\n")
cat("GO terms analyzed:", length(unique(go_gene_table$GO_ID)), "\n")
cat("OA-up gene-term associations:",
    sum(go_gene_table$direction == "OA_up"), "\n")
cat("OA-down gene-term associations:",
    sum(go_gene_table$direction == "OA_down"), "\n")
cat("Unique OA-up genes:", length(up_unique), "\n")
cat("Unique OA-down genes:", length(down_unique), "\n")

cat("\nSaved: results/go_top10_term_genes.csv\n")
cat("Saved: results/go_OA_up_unique_genes.csv\n")
cat("Saved: results/go_OA_down_unique_genes.csv\n")
