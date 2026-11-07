
# ============================================================
# Linear models for PCA covariates
# Dataset: GSE114007 | GPL18573
# ============================================================

pca_data <- read.csv(
  "results/pca_coordinates.csv",
  stringsAsFactors = FALSE
)

pca_data$group <- factor(
  pca_data$group,
  levels = c("Normal", "OA")
)

pca_data$sex <- factor(pca_data$sex)

# Model A: Age only
model_age <- lm(PC1 ~ age, data = pca_data)

# Model B: Age, group, and sex
model_adjusted <- lm(
  PC1 ~ age + group + sex,
  data = pca_data
)

cat("\n--- Model A: Age only ---\n")
print(summary(model_age))

cat("\n--- Model B: Age + Group + Sex ---\n")
print(summary(model_adjusted))

cat("\n--- Model comparison ---\n")
print(anova(model_age, model_adjusted))

# Save model coefficients
write.csv(
  as.data.frame(coef(summary(model_age))),
  "results/pca_model_age.csv"
)

write.csv(
  as.data.frame(coef(summary(model_adjusted))),
  "results/pca_model_adjusted.csv"
)

cat("\nModel analysis completed.\n")
