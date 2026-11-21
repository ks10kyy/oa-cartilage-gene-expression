
-- ============================================================
-- OA Cartilage Gene Expression Portfolio
-- SQL analysis queries
-- Database: oa_cartilage_db
-- ============================================================


-- 1. Count significant genes in each DESeq2 model
-- Significance threshold: adjusted p-value < 0.1

SELECT
    model_name,
    COUNT(*) FILTER (
        WHERE padj < 0.1
    ) AS significant_genes
FROM deseq2_results
GROUP BY model_name
ORDER BY model_name;


-- 2. Compare mean normalized expression
-- between Normal and OA groups
-- Descriptive fold change = OA mean / Normal mean
-- This is not the DESeq2 model-based log2 fold change.

SELECT
    nc.gene_symbol,

    AVG(nc.normalized_count)
        FILTER (
            WHERE s.group_name = 'Normal'
        ) AS normal_mean,

    AVG(nc.normalized_count)
        FILTER (
            WHERE s.group_name = 'OA'
        ) AS oa_mean,

    AVG(nc.normalized_count)
        FILTER (
            WHERE s.group_name = 'OA'
        )
    /
    NULLIF(
        AVG(nc.normalized_count)
            FILTER (
                WHERE s.group_name = 'Normal'
            ),
        0
    ) AS descriptive_fold_change

FROM normalized_counts AS nc

JOIN samples AS s
    ON nc.sample = s.sample

WHERE nc.gene_symbol IN (
    'MMP13',
    'ADAMTS5',
    'COL2A1',
    'COMP',
    'ACAN'
)

GROUP BY nc.gene_symbol
ORDER BY nc.gene_symbol;


-- 3. Compare DESeq2 results with normalized expression
-- Adjusted model: OA vs Normal
-- Include all five selected genes, regardless of significance.

SELECT
    d.gene_symbol,
    d.log2_fold_change,
    d.padj,

    AVG(n.normalized_count)
        FILTER (
            WHERE s.group_name = 'Normal'
        ) AS normal_mean,

    AVG(n.normalized_count)
        FILTER (
            WHERE s.group_name = 'OA'
        ) AS oa_mean

FROM deseq2_results AS d

JOIN normalized_counts AS n
    ON d.gene_symbol = n.gene_symbol

JOIN samples AS s
    ON n.sample = s.sample

WHERE
    d.model_name = 'adjusted'
    AND d.gene_symbol IN (
        'MMP13',
        'ADAMTS5',
        'COL2A1',
        'COMP',
        'ACAN'
    )

GROUP BY
    d.gene_symbol,
    d.log2_fold_change,
    d.padj

ORDER BY d.padj NULLS LAST;
