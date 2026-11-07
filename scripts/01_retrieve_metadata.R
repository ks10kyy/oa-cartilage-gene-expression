# GSE114007: Retrieve GEO sample metadata

# 1. Check whether GEOquery is installed.
if (!requireNamespace("GEOquery", quietly = TRUE)) {
    stop("GEOquery is not installed in this R environment.")
}

# 2. Load GEOquery.
library(GEOquery)

# 3. Retrieve the GEO record.
message("Retrieving GSE114007 from NCBI GEO...")
gse <- getGEO("GSE114007", GSEMatrix = FALSE)

# 4. Extract individual sample records.
gsm_list <- GSMList(gse)

message("Number of GEO samples retrieved: ", length(gsm_list))

# 5. Extract a metadata field.
get_field <- function(metadata, field) {
    value <- metadata[[field]]

    if (is.null(value) || length(value) == 0) {
        return(NA_character_)
    }

    paste(as.character(value), collapse = "; ")
}

# 6. Extract age, sex, and OA grade from sample characteristics.
get_characteristic <- function(characteristics, pattern) {
    if (is.null(characteristics) || length(characteristics) == 0) {
        return(NA_character_)
    }

    matched <- grep(
        pattern,
        characteristics,
        ignore.case = TRUE,
        value = TRUE
    )

    if (length(matched) == 0) {
        return(NA_character_)
    }

    sub("^[^:]+:\\s*", "", matched[1])
}

# 7. Build a summary table.
sample_summary <- do.call(
    rbind,
    lapply(gsm_list, function(sample) {
        m <- Meta(sample)
        characteristics <- m[["characteristics_ch1"]]

        if (is.null(characteristics)) {
            characteristics <- character(0)
        }

        characteristics_text <- if (length(characteristics) == 0) {
            NA_character_
        } else {
            paste(as.character(characteristics), collapse = "; ")
        }

        data.frame(
            accession = get_field(m, "geo_accession"),
            title = get_field(m, "title"),
            platform = get_field(m, "platform_id"),
            instrument = get_field(m, "instrument_model"),
            source = get_field(m, "source_name_ch1"),
            characteristics = characteristics_text,
            age = get_characteristic(characteristics, "^age\\s*:"),
            sex = get_characteristic(characteristics, "^sex\\s*:"),
            oa_grade = get_characteristic(characteristics, "^oa grade\\s*:"),
            stringsAsFactors = FALSE
        )
    })
)

# 8. Save the results to a new CSV file.
output_file <- file.path(
    "data",
    "processed",
    "GSE114007_GEO_sample_metadata.csv"
)

write.csv(
    sample_summary,
    output_file,
    row.names = FALSE,
    na = ""
)

# 9. Display basic validation results.
message("Sample records retrieved: ", nrow(sample_summary))

message("Samples by platform:")
print(table(sample_summary$platform, useNA = "ifany"))

message(
    "Samples with missing age information: ",
    sum(is.na(sample_summary$age) | sample_summary$age == "")
)

message(
    "Samples with missing sex information: ",
    sum(is.na(sample_summary$sex) | sample_summary$sex == "")
)

message(
    "Samples with missing OA grade information: ",
    sum(is.na(sample_summary$oa_grade) | sample_summary$oa_grade == "")
)

message("Metadata saved to: ", output_file)
