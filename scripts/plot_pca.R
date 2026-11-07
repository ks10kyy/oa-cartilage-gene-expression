# ============================================================
# PCA visualization: Normal vs OA cartilage
# Dataset: GSE114007, platform GPL18573
# Transformation: DESeq2 variance stabilizing transformation
# ============================================================

suppressPackageStartupMessages({
  library(DESeq2)
  library(ggplot2)
})

# 1. Define file paths
count_file <- "data/processed/counts_GPL18573_raw.csv"
metadata_file <- "data/processed/metadata_deseq2.csv"
output_dir <- "results"

dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# 2. Load count matrix and metadata
counts_df <- read.csv(
  count_file,
  check.names = FALSE,
  stringsAsFactors = FALSE
)

metadata <- read.csv(
  metadata_file,
  stringsAsFactors = FALSE
)

# 3. Build count matrix
gene_symbols <- counts_df$symbol
count_data <- counts_df[, setdiff(colnames(counts_df), "symbol"), drop = FALSE]

rownames(count_data) <- gene_symbols

count_matrix <- as.matrix(count_data)
storage.mode(count_matrix) <- "integer"

# 4. Validate sample information
stopifnot(!anyDuplicated(rownames(count_matrix)))
stopifnot(!anyNA(count_matrix))
stopifnot(all(count_matrix >= 0))

stopifnot(setequal(colnames(count_matrix), metadata$sample))

metadata <- metadata[
  match(colnames(count_matrix), metadata$sample),
]

rownames(metadata) <- metadata$sample

stopifnot(identical(rownames(metadata), colnames(count_matrix)))

# 5. Define categorical variables
metadata$group <- factor(
  metadata$group,
  levels = c("Normal", "OA")
)

metadata$sex <- factor(
  metadata$sex,
  levels = c("F", "M")
)

# 6. Create DESeq2 dataset
dds <- DESeqDataSetFromMatrix(
  countData = count_matrix,
  colData = metadata,
  design = ~ group
)

# 7. Apply variance stabilizing transformation
vsd <- vst(dds, blind = FALSE)

# 8. Perform PCA using the 500 most variable genes
pca_data <- plotPCA(
  vsd,
  intgroup = "group",
  ntop = 500,
  returnData = TRUE
)

percentVar <- round(
  100 * attr(pca_data, "percentVar"),
  1
)

# 9. Add sample information
pca_data$sample <- pca_data$name

sample_info <- as.data.frame(colData(vsd))

pca_data$sex <- sample_info[pca_data$sample, "sex"]
pca_data$age <- sample_info[pca_data$sample, "age"]

# 10. Create PCA plot
p <- ggplot(
  pca_data,
  aes(x = PC1, y = PC2, color = group, shape = sex)
) +
  geom_point(size = 4) +
  geom_text(
    aes(label = sample),
    vjust = -1,
    size = 3,
    show.legend = FALSE
  ) +
  labs(
    title = "PCA: Normal vs OA cartilage",
    subtitle = "GSE114007 | GPL18573 | Top 500 variable genes",
    x = paste0("PC1: ", percentVar[1], "% variance"),
    y = paste0("PC2: ", percentVar[2], "% variance"),
    color = "Group",
    shape = "Sex"
  ) +
  theme_bw()

# 11. Save PCA plot
ggsave(
  filename = file.path(output_dir, "pca_plot.png"),
  plot = p,
  width = 9,
  height = 7,
  dpi = 300
)

# 12. Save PCA coordinates
write.csv(
  pca_data,
  file.path(output_dir, "pca_coordinates.csv"),
  row.names = FALSE
)

# 13. Print summary
cat("\n--- PCA analysis completed ---\n")
cat("Number of samples:", nrow(pca_data), "\n")
cat("Genes used for PCA: 500\n")
cat("PC1 variance:", percentVar[1], "%\n")
cat("PC2 variance:", percentVar[2], "%\n")

cat("\nFiles saved:\n")
cat("results/pca_plot.png\n")
cat("results/pca_coordinates.csv\n")
