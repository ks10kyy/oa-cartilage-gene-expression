
# ============================================================
# PCA covariate analysis: Age and sex
# Dataset: GSE114007 | GPL18573
# ============================================================

suppressPackageStartupMessages({
  library(ggplot2)
})

# 1. Load PCA coordinates
pca_data <- read.csv(
  "results/pca_coordinates.csv",
  stringsAsFactors = FALSE
)

# 2. Check required columns
required_columns <- c(
  "name", "PC1", "PC2", "group", "sex", "age"
)

if (!all(required_columns %in% colnames(pca_data))) {
  stop("Required columns are missing from pca_coordinates.csv")
}

# 3. Convert categorical variables into factors
pca_data$group <- factor(
  pca_data$group,
  levels = c("Normal", "OA")
)

pca_data$sex <- factor(pca_data$sex)

# 4. Plot PCA with age represented by color
p_age <- ggplot(
  pca_data,
  aes(x = PC1, y = PC2, color = age, shape = group)
) +
  geom_point(size = 4) +
  geom_text(
    aes(label = name),
    vjust = -1,
    size = 3,
    show.legend = FALSE
  ) +
  scale_color_gradient(
    low = "blue",
    high = "red"
  ) +
  labs(
    title = "PCA colored by age",
    subtitle = "GSE114007 | GPL18573 | Top 500 variable genes",
    x = "PC1 (47% variance)",
    y = "PC2 (15.6% variance)",
    color = "Age",
    shape = "Group"
  ) +
  theme_bw()

ggsave(
  "results/pca_age_plot.png",
  p_age,
  width = 9,
  height = 7,
  dpi = 300
)

# 5. Plot PC1 against age
p_pc1_age <- ggplot(
  pca_data,
  aes(x = age, y = PC1, color = group, shape = sex)
) +
  geom_point(size = 4) +
  geom_text(
    aes(label = name),
    vjust = -1,
    size = 3,
    show.legend = FALSE
  ) +
  geom_smooth(
    method = "lm",
    formula = y ~ x,
    se = FALSE
  ) +
  labs(
    title = "Relationship between age and PC1",
    x = "Age (years)",
    y = "PC1",
    color = "Group",
    shape = "Sex"
  ) +
  theme_bw()

ggsave(
  "results/pca_pc1_age_plot.png",
  p_pc1_age,
  width = 9,
  height = 7,
  dpi = 300
)

# 6. Calculate exploratory Spearman correlation
cor_result <- cor.test(
  pca_data$age,
  pca_data$PC1,
  method = "spearman",
  exact = FALSE
)

cat("\n--- PCA covariate analysis ---\n")
cat("Number of samples:", nrow(pca_data), "\n")
cat("Spearman correlation between age and PC1:\n")
print(cor_result)

cat("\nFiles saved:\n")
cat("results/pca_age_plot.png\n")
cat("results/pca_pc1_age_plot.png\n")
