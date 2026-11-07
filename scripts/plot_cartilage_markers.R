library(ggplot2)
library(tidyr)
library(dplyr)

# Load normalized expression data and sample metadata
counts <- read.csv(
  "results/deseq2_normalized_counts.csv",
  check.names = FALSE
)

metadata <- read.csv(
  "data/processed/metadata_deseq2.csv",
  check.names = FALSE
)

# Select five cartilage-related genes
markers <- c("MMP13", "ADAMTS5", "COL2A1", "COMP", "ACAN")

# Check that all genes are present
marker_counts <- counts %>%
  filter(gene_symbol %in% markers)

if (!all(markers %in% marker_counts$gene_symbol)) {
  stop("One or more marker genes were not found.")
}

# Convert the expression table into long format
expression_long <- marker_counts %>%
  pivot_longer(
    cols = -gene_symbol,
    names_to = "sample",
    values_to = "normalized_count"
  )

# Add group information to each sample
expression_long <- expression_long %>%
  left_join(metadata, by = "sample")

if (any(is.na(expression_long$group))) {
  stop("Some samples could not be matched with metadata.")
}

# Set display order
expression_long$gene_symbol <- factor(
  expression_long$gene_symbol,
  levels = markers
)

expression_long$group <- factor(
  expression_long$group,
  levels = c("Normal", "OA")
)

# Create the plot
p <- ggplot(
  expression_long,
  aes(x = group, y = normalized_count, fill = group)
) +
  geom_boxplot(
    width = 0.55,
    alpha = 0.5,
    outlier.shape = NA
  ) +
  geom_jitter(
    width = 0.12,
    size = 2,
    alpha = 0.8
  ) +
  facet_wrap(
    ~ gene_symbol,
    scales = "free_y"
  ) +
  scale_y_continuous(
    trans = "log10",
    name = "Normalized counts (log10 scale)"
  ) +
  labs(
    title = "Expression of Cartilage-Related Genes",
    subtitle = "Normal vs OA cartilage samples",
    x = "Group",
    caption = "Each point represents one sample. Y-axis uses a log10 scale."
  ) +
  theme_bw() +
  theme(
    legend.position = "none",
    strip.text = element_text(face = "bold"),
    plot.title = element_text(face = "bold")
  )

# Save the figure
ggsave(
  "results/cartilage_marker_expression.png",
  plot = p,
  width = 11,
  height = 7,
  dpi = 300
)

cat("Plot saved: results/cartilage_marker_expression.png\n")
cat("Samples:", length(unique(expression_long$sample)), "\n")
print(table(metadata$group))
