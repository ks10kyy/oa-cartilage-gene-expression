
# ============================================================
# Differential gene expression analysis: Normal vs OA cartilage
# Dataset: GSE114007, platform GPL18573
# Primary model:   ~ group
# Sensitivity model: ~ age + sex + group
# ============================================================

suppressPackageStartupMessages({
  library(DESeq2)
})

# 1. Define input and output paths
count_file <- "data/processed/counts_GPL18573_raw.csv"
metadata_file <- "data/processed/metadata_deseq2.csv"
output_dir <- "results"

dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# 2. Load the count matrix and metadata
counts_df <- read.csv(
  count_file,
  check.names = FALSE,
  stringsAsFactors = FALSE
)

metadata <- read.csv(
  metadata_file,
  stringsAsFactors = FALSE
)

# 3. Check required columns
stopifnot("symbol" %in% colnames(counts_df))
stopifnot(all(c("sample", "group", "age", "sex") %in% colnames(metadata)))

# 4. Build the count matrix
gene_symbols <- counts_df$symbol
count_data <- counts_df[, setdiff(colnames(counts_df), "symbol"), drop = FALSE]

rownames(count_data) <- gene_symbols

# Convert the count data to a numeric matrix
count_matrix <- as.matrix(count_data)
storage.mode(count_matrix) <- "integer"

# 5. Validate sample names and count values
if (!setequal(colnames(count_matrix), metadata$sample)) {
  stop("Sample names in the count matrix and metadata do not match.")
}

if (anyDuplicated(rownames(count_matrix)) > 0) {
  stop("Duplicate gene symbols found.")
}

if (anyNA(count_matrix) || any(count_matrix < 0)) {
  stop("Count matrix contains missing or negative values.")
}

if (any(count_matrix %% 1 != 0)) {
  stop("Count matrix contains non-integer values.")
}

# Reorder metadata to match the count matrix
metadata <- metadata[match(colnames(count_matrix), metadata$sample), ]

stopifnot(identical(metadata$sample, colnames(count_matrix)))

# 6. Set reference categories
metadata$group <- factor(metadata$group, levels = c("Normal", "OA"))
metadata$sex <- factor(metadata$sex, levels = c("F", "M"))
metadata$age <- as.numeric(metadata$age)

if (anyNA(metadata[, c("group", "sex", "age")])) {
  stop("Missing or invalid group, sex, or age values.")
}

# 7. Primary analysis: group only
dds_primary <- DESeqDataSetFromMatrix(
  countData = count_matrix,
  colData = metadata,
  design = ~ group
)

dds_primary <- DESeq(dds_primary)

res_primary <- results(
  dds_primary,
  contrast = c("group", "OA", "Normal")
)

res_primary_df <- as.data.frame(res_primary)
res_primary_df$gene_symbol <- rownames(res_primary_df)
res_primary_df <- res_primary_df[
  order(res_primary_df$padj, na.last = TRUE),
]

write.csv(
  res_primary_df,
  file.path(output_dir, "deseq2_primary_group.csv"),
  row.names = FALSE
)

# Save normalized counts for downstream inspection
normalized_counts <- counts(dds_primary, normalized = TRUE)
normalized_counts_df <- as.data.frame(normalized_counts)
normalized_counts_df$gene_symbol <- rownames(normalized_counts_df)

write.csv(
  normalized_counts_df,
  file.path(output_dir, "deseq2_normalized_counts.csv"),
  row.names = FALSE
)

# 8. Sensitivity analysis: adjust for age and sex
# Standardize age to improve numerical conditioning
metadata$age_scaled <- as.numeric(scale(metadata$age))

# Create adjusted DESeq2 dataset
dds_adjusted <- DESeqDataSetFromMatrix(
  countData = count_matrix,
  colData = metadata,
  design = ~ age_scaled + sex + group
)

dds_adjusted <- DESeq(dds_adjusted)

dds_adjusted <- DESeq(dds_adjusted)

res_adjusted <- results(
  dds_adjusted,
  contrast = c("group", "OA", "Normal")
)

res_adjusted_df <- as.data.frame(res_adjusted)
res_adjusted_df$gene_symbol <- rownames(res_adjusted_df)
res_adjusted_df <- res_adjusted_df[
  order(res_adjusted_df$padj, na.last = TRUE),
]

write.csv(
  res_adjusted_df,
  file.path(output_dir, "deseq2_adjusted_age_sex.csv"),
  row.names = FALSE
)

# 9. Print a summary
cat("\nPrimary analysis results:\n")
print(summary(res_primary))

cat("\nAdjusted analysis results:\n")
print(summary(res_adjusted))

cat("\nAnalysis complete. Results saved in:", output_dir, "\n")
