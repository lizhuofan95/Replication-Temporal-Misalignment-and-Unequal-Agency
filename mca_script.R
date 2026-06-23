# =============================================================================
# 
# MCA Replication code for Li, Zhuofan, Daniel Dohan, and Corey M. Abramson. 2026. “Temporal Misalignment and Unequal Agency: What Terminal Cancer Patients Teach Us about Time and Inequality.” American Sociological Review (00031224261448220). doi:10.1177/00031224261448220.
#
# =============================================================================

# setwd("path/to/replication")

# -----------------------------------------------------------------------------
# Install & load required packages
# -----------------------------------------------------------------------------
required <- c("tidyverse", "magrittr", "FactoMineR", "factoextra", "ggsci",
              "sjPlot", "flextable", "ragg", "ggrepel")
missing  <- setdiff(required, rownames(installed.packages()))
if (length(missing)) install.packages(missing)

library(tidyverse)
library(dplyr)
library(magrittr)
library(ggplot2)
library(FactoMineR)
library(factoextra)
library(ggsci)
library(sjPlot)
library(flextable)
library(ragg)
library(ggrepel)

set.seed(123)  # insurance for HCPC k-means consolidation (pipeline is deterministic)

# -----------------------------------------------------------------------------
# Load & prepare data
# -----------------------------------------------------------------------------
data <- read_csv("mca_data.csv") %>% column_to_rownames(var = "id")

data <- data %>% mutate(schedule_conflict = (schedule_work + schedule_family + schedule_organization)>=1,
         trajectory_mismatch = (trajectory_economic + trajectory_medical)>=1,
                   anticipant_uncertainty = anticipant) %>%
  select(-schedule_work, -schedule_family, -schedule_organization,
                   -trajectory_economic, -trajectory_medical,
                   -anticipant)

data <- data %>% mutate(schedule_conflict = factor(schedule_conflict, labels = c('has_schedule_conflict', 'no_schedule_conflict'))) %>%
  mutate(trajectory_mismatch = factor(trajectory_mismatch, labels = c('has_trajectory_mismatch', 'no_trajectory_mismatch'))) %>%
  mutate(anticipant_uncertainty = factor(anticipant_uncertainty, labels = c('has_anticipant_uncertainty', 'no_anticipant_uncertainty')))

# Convert all analysis columns to factors (MCA requires categorical input).
data <- data %>% mutate(across(everything(), as.factor))

#data <- read.csv("mca_data.csv") %>%
#  column_to_rownames(var = "X")

# -----------------------------------------------------------------------------
# Full MCA
# -----------------------------------------------------------------------------
fullmca <- MCA(data)

plot.MCA(fullmca)

fviz_mca_biplot(fullmca,
                map = "rowprincipal",
                repel = TRUE)

fviz_mca_biplot(fullmca,
                map = "rowprincipal",
                repel = TRUE,
                col.var = "contrib",
                gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                select.ind = list(contrib = 25),
                ggtheme = theme_minimal(),
                title = "Full MCA Biplot (individuals in principal coordinates)"
                )

fullmca$var$contrib

# -----------------------------------------------------------------------------
# Reduced MCA (capital by temporal misalignment only)
#
# Restricts the active variables to the capital variables (householdsize,
# education, householdincome, employed) and the three temporal-misalignment
# variables (schedule_conflict, trajectory_mismatch, anticipant_uncertainty),
# so the axes are built to reflect the association between resource disparities
# and temporal misalignment. Every other variable is kept in the figure as quali.sup
# (supplementary/passive): projected onto the axes to aid interpretation, but not
# used to build them.
# -----------------------------------------------------------------------------

sup_vars <- c("pt_gender", "race", "marital_status", "ownhome",
              "anytrial", "cancertype", "midwestcity", "proactive", "age") 

reducedmca <- MCA(data, quali.sup = which(names(data) %in% sup_vars))

fviz_mca_biplot(reducedmca,
                map = "rowprincipal",
                repel = TRUE,
                col.var = "contrib",
                gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                select.ind = list(contrib = 50),
                ggtheme = theme_minimal(),
                title = "Reduced MCA Biplot (individuals in principal coordinates)"
)

# -----------------------------------------------------------------------------
# Hierarchical clustering & Figure 1
# -----------------------------------------------------------------------------
clst <- HCPC(reducedmca, metric = "manhattan", nb.clust = 4)  # nb.clust = 4: chosen by researcher judgment after sweeping 3-6 cluster solutions

clst$data.clust$clust <- factor(clst$data.clust$clust,
                                levels = c(1, 2, 3, 4),
                                labels = c("Upper-Middle Class", "Middle Class", "Lower-Middle Class", "Working Class"))

fviz_mca_biplot(reducedmca,
                     map = "rowprincipal",
                     repel = TRUE,
                     palette = "jama",
                     select.ind = list(contrib = 20),
                     select.var = list(contrib = 30),
                     ggtheme = theme_minimal(),
                     title = "Reduced MCA Biplot (individuals in principal coordinates)",
                     habillage = clst$data.clust$clust
)

p <- fviz_mca_biplot(reducedmca,
                map = "rowprincipal",
                repel = TRUE,
                palette = "jama",
                select.var = list(name = c("Large_Family", "Small_Family", "High School or Less", "Bachelor's Degree", "Graduate Degree", "Below 20K", "Above 100k", "not_working", "working_parttime", "working_fulltime", "has_schedule_conflict", "no_schedule_conflict", "has_trajectory_mismatch", "no_trajectory_mismatch", "has_anticipant_uncertainty", "no_anticipant_uncertainty")),
                ggtheme = theme_minimal(),
                title = "Reduced MCA Biplot (individuals in principal coordinates)",
                addEllipses =TRUE,
                habillage = clst$data.clust$clust,
                labelsize = 6
) +
  theme(
    legend.title = element_text(size = 12),
    legend.text  = element_text(size = 12),
    legend.key.size = unit(1.2, "cm")
  )

p

ggsave(
  filename = "reduced_mca_biplot.tiff",
  plot = p,
  device = ragg::agg_tiff,
  dpi = 300,
  compression = "lzw"
)


fviz_mca_var(reducedmca,
                map = "symmetric",
                repel = TRUE,
                palette = "jama",
                select.var = list(name = c("Large_Family", "Small_Family", "High School or Less", "Bachelor's Degree", "Graduate Degree", "Below 20K", "Above 100k", "not_working", "working_parttime", "working_fulltime", "has_schedule_conflict", "no_schedule_conflict", "has_trajectory_mismatch", "no_trajectory_mismatch", "has_anticipant_uncertainty", "no_anticipant_uncertainty", "[28,50)", "[50,65)", "[65,80)", "Gastrointestinal", "Breast", "Melanoma", "Genitourinary", "Lung", "Gynecologic")),
                ggtheme = theme_minimal(),
                title = "Reduced MCA Variable Plot"
)

fviz_ellipses(reducedmca, clst$data.clust$clust)

fviz_mca_biplot(reducedmca,
                map = "rowprincipal",
                repel = TRUE,
                palette = "jama",
                select.ind = list(name = c("7528", "7069", "4040", "7037")),
                select.var = list(contrib = 20),
                ggtheme = theme_minimal(),
                title = "Reduced MCA Biplot (individuals in principal coordinates)",
                habillage = clst$data.clust$clust
)

fviz_mca_biplot(reducedmca,
                map = "rowprincipal",
                repel = TRUE,
                palette = "jama",
                select.ind = list(name = c("7072", "4022", "7038", "4040")),
                select.var = list(contrib = 20),
                ggtheme = theme_minimal(),
                title = "Reduced MCA Biplot (individuals in principal coordinates)",
                habillage = clst$data.clust$clust
)

fviz_mca_biplot(reducedmca,
                map = "rowprincipal",
                repel = TRUE,
                palette = "jama",
                select.ind = list(name = c("4040", "4039", "7073", "7037")),
                select.var = list(contrib = 20),
                ggtheme = theme_minimal(),
                title = "Reduced MCA Biplot (individuals in principal coordinates)",
                habillage = clst$data.clust$clust
)

reducedmca$var

# -----------------------------------------------------------------------------
# Supplementary tables
# -----------------------------------------------------------------------------
# Table A2 -- variance in individual coordinates explained by variables (R2)
R2dim1 <- dimdesc(reducedmca)$`Dim 1`$quali %>% data.frame() %>% rownames_to_column() %>% tibble()

R2dim2 <- dimdesc(reducedmca)$`Dim 2`$quali %>% data.frame() %>% rownames_to_column() %>% tibble()

R2dim3 <- dimdesc(reducedmca)$`Dim 3`$quali %>% data.frame() %>% rownames_to_column() %>% tibble()

R2 <- R2dim1 %>%
  full_join(R2dim2, by = "rowname") %>%
  full_join(R2dim3, by = "rowname") %>%
  rename(Variables = rowname)

typology <- data.frame(
  col_keys = c( "R2.x", "p.value.x",
                "R2.y", "p.value.y",
                "R2", "p.value"),
  what = c("Dim1", "Dim1", "Dim2", "Dim2", "Dim3", "Dim3"),
  measure = c("R2", "p.value", "R2", "p.value", "R2", "p.value"),
  stringsAsFactors = FALSE )

R2 %>% flextable() %>%
  colformat_double(digits = 2) %>%
  set_header_df(mapping = typology, key = "col_keys") %>%
  merge_h(part = "header") %>%
  theme_vanilla() %>%
  fix_border_issues() %>%
  save_as_docx(path = "R2Time.docx")

# Table A3 -- individual coordinates vs. the average for given categories
top_n_rows <- 5

Cordim1 <- dimdesc(reducedmca)$`Dim 1`$category %>% data.frame() %>% rownames_to_column() %>% tibble() %>%
  arrange(Estimate) %>%  slice(sort(c(seq_len(top_n_rows),  n() - seq_len(top_n_rows) + 1)))

Cordim2 <- dimdesc(reducedmca)$`Dim 2`$category %>% data.frame() %>% rownames_to_column() %>% tibble() %>%
  arrange(Estimate) %>%  slice(sort(c(seq_len(top_n_rows),  n() - seq_len(top_n_rows) + 1)))

Cordim3 <- dimdesc(reducedmca)$`Dim 3`$category %>% data.frame() %>% rownames_to_column() %>% tibble() %>%
  arrange(Estimate) %>%  slice(sort(c(seq_len(top_n_rows),  n() - seq_len(top_n_rows) + 1)))

Cor <- Cordim1 %>%
  full_join(Cordim2, by = "rowname") %>%
  full_join(Cordim3, by = "rowname") %>%
  rename(Category = rowname)

typology_Cor <- data.frame(
  col_keys = c( "Estimate.x", "p.value.x",
                "Estimate.y", "p.value.y",
                "Estimate", "p.value"),
  what = c("Dim1", "Dim1", "Dim2", "Dim2", "Dim3", "Dim3"),
  measure = c("Corr", "p.value", "Corr", "p.value", "Corr", "p.value"),
  stringsAsFactors = FALSE)

Cor %>% flextable() %>%
  colformat_double(digits = 2) %>%
  set_header_df(mapping = typology_Cor, key = "col_keys") %>%
  merge_h(part = "header") %>%
  theme_vanilla() %>%
  fix_border_issues() %>%
  save_as_docx(path = "Corr.docx")

# Table A1 -- contribution to principal axis inertia (%)
variance = reducedmca$eig[1:5,2]
names(variance) <- c("Dim 1", "Dim 2", "Dim 3", "Dim 4", "Dim 5")
tve = data.frame(Categories = "% Total Variance Explained", variance) %>% rownames_to_column() %>% pivot_wider(names_from = rowname, values_from = variance)

as.data.frame(reducedmca$var$contrib) %>%
  rownames_to_column("Categories") %>%
  bind_rows(summarise(.,
                        across(where(is.numeric), sum),
                        across(where(is.character), ~"% Variance"))) %>%
  bind_rows(tve) %>%
  flextable() %>%
  set_caption(caption = "Contribution to Principal Axes (in %)") %>%
  colformat_double(digits = 2) %>%
  save_as_docx(path = "contribution.docx")

dimdesc(reducedmca)$`Dim 1`$category