
# ============================================================
# Diagnose age-group confounding
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

# 1. Compare age distributions
cat("\n--- Age distribution by group ---\n")

print(
  aggregate(
    age ~ group,
    data = pca_data,
    FUN = function(x) {
      c(
        n = length(x),
        min = min(x),
        median = median(x),
        mean = mean(x),
        max = max(x)
      )
    }
  )
)

# 2. Calculate age-group correlation
group_numeric <- as.numeric(pca_data$group == "OA")

cat("\n--- Correlation between age and OA status ---\n")

print(
  cor.test(
    pca_data$age,
    group_numeric,
    method = "pearson"
  )
)

# 3. Calculate confidence intervals for Model B
model_adjusted <- lm(
  PC1 ~ age + group + sex,
  data = pca_data
)

cat("\n--- Model B: 95% confidence intervals ---\n")

print(confint(model_adjusted))

# 4. Check predictor correlations and model conditioning
predictors <- data.frame(
  age = as.numeric(scale(pca_data$age)),
  groupOA = group_numeric,
  sexM = as.numeric(pca_data$sex == "M")
)

cat("\n--- Predictor correlation matrix ---\n")
print(cor(predictors))

cat("\n--- Condition number of standardized predictors ---\n")
print(kappa(as.matrix(predictors)))

cat("\nDiagnostic analysis completed.\n")
