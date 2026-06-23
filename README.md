# Replication: Temporal Misalignment and Unequal Agency

Replication materials for the multiple correspondence analysis (MCA) and
hierarchical clustering reported in:

> Li, Zhuofan, Daniel Dohan, and Corey M. Abramson. 2026. "Temporal Misalignment
> and Unequal Agency: What Terminal Cancer Patients Teach Us about Time and
> Inequality." *American Sociological Review*.
> doi:[10.1177/00031224261448220](https://doi.org/10.1177/00031224261448220)

## Overview

`mca_script.R` constructs a social space defined by forms of capital and indicators of temporal misalignment among 73 terminal cancer patients who agreed to share their demographic information, derives a social-class typology via hierarchical clustering, and reproduces the paper's MCA figure and supplementary tables.

## Repository contents

| File | Description |
| --- | --- |
| `mca_script.R` | Full analysis pipeline: data prep, MCA, HCPC clustering, and figure/table export. |
| `mca_data.csv` | De-identified analysis dataset (one row per participant). |
| `README.md` | This file. |
| `LICENSE` | MIT License. |

## Reproduced outputs

Running the script writes these files to the working directory:

| Script output | Paper element | Contents |
| --- | --- | --- |
| `reduced_mca_biplot.tiff` | **Figure 1** | Reduced MCA biplot with class clusters. |
| `contribution.docx` | **Table A1** (Online Supplement) | Contribution to principal axis inertia (%). |
| `R2Time.docx` | **Table A2** (Online Supplement) | Variance in individual coordinates explained by variables (R²). |
| `Corr.docx` | **Table A3** (Online Supplement) | Category coordinates relative to the average on each principal axis. |

## Data

`mca_data.csv` contains 73 rows and 20 columns: an anonymized `id` plus 19
variables. 

### Codebook

| Variable | Values | Role in MCA |
| --- | --- | --- |
| `id` | participant identifier | row label (not analyzed) |
| `householdsize` | Small_Family, Medium_Family, Large_Family | **active** |
| `education` | High School or Less; Associate/Vocational or Some College; Bachelor's Degree; Graduate Degree | **active** |
| `householdincome` | Below 20K; 20K-40K; 40K-60K; 60K-80K; 80K-100K; Above 100k | **active** |
| `employed` | not_working, working_parttime, working_fulltime | **active** |
| `schedule_work` | 0/1 | source for `schedule_conflict` (see below) |
| `schedule_family` | 0/1 | source for `schedule_conflict` |
| `schedule_organization` | 0/1 | source for `schedule_conflict` |
| `trajectory_medical` | 0/1 | source for `trajectory_mismatch` |
| `trajectory_economic` | 0/1 | source for `trajectory_mismatch` |
| `anticipant` | 0/1 | source for `anticipant_uncertainty` |
| `pt_gender` | female, male | supplementary |
| `race` | white, black, asian, mixed, hispanic white | supplementary |
| `marital_status` | Married/Partnered, NeverMarried, Divorced/Separated, Widowed | supplementary |
| `ownhome` | homeowner, nonhomeowner | supplementary |
| `anytrial` | 0/1 | supplementary |
| `cancertype` | Breast, Gastrointestinal, Genitourinary, Gynecologic, Lung, Melanoma | supplementary |
| `midwestcity` | 0/1 (field-site indicator) | supplementary |
| `proactive` | proactive, defensive | supplementary |
| `age` | [28,50), [50,65), [65,80), [80,95] | supplementary |

**Derived analysis variables** (constructed in `mca_script.R`):

| Variable | Definition |
| --- | --- |
| `schedule_conflict` | 1 if `schedule_work + schedule_family + schedule_organization >= 1` |
| `trajectory_mismatch` | 1 if `trajectory_economic + trajectory_medical >= 1` |
| `anticipant_uncertainty` | 1 if `anticipant >= 1` |

*Active* variables build the MCA axes; *supplementary* variables are projected
onto those axes for interpretation but do not shape them.

## Version requirements

- **R** — developed under version 4.4.1.
- **R packages:**

  | Package | Version |
  | --- | --- |
  | tidyverse | 2.0.0 |
  | magrittr | 2.0.3 |
  | FactoMineR | 2.11 |
  | factoextra | 1.0.7 |
  | ggsci | 3.2.0 |
  | sjPlot | 2.8.17 |
  | flextable | 0.9.7 |
  | ragg | 1.5.1 |
  | ggrepel | 0.9.6 |

## Contact

For questions about the replication materials, contact: Zhuofan Li at [zhuofan@vt.edu](mailto:zhuofan@vt.edu)