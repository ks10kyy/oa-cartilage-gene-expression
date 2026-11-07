primary <- read.csv("results/deseq2_primary_group.csv")
adjusted <- read.csv("results/deseq2_adjusted_age_sex.csv")

valid_primary <- primary$gene_symbol[!is.na(primary$pvalue)]
valid_adjusted <- adjusted$gene_symbol[!is.na(adjusted$pvalue)]

background <- intersect(valid_primary, valid_adjusted)

cat("Genes testable in both models:", length(background), "\n")

cat("Genes testable only in primary:",
    length(setdiff(valid_primary, valid_adjusted)), "\n")

cat("Genes testable only in adjusted:",
    length(setdiff(valid_adjusted, valid_primary)), "\n")
