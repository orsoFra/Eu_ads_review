# README

## Overview

This repository contains the code used to reproduce the analyses in:

**“Gender-based discrepancies in the algorithmic delivery of political ads on social media.”**

The paper studies gender-based differences in the delivery of political advertisements on Facebook and Instagram during the 2024 European Parliament elections.

The main analysis is contained in `analysis_ads.Rmd`. Helper functions are contained in `utils.R`.

## Data Availability and Provenance

The analysis combines data from the following sources:

| Data source | Description | Provided |
| --- | --- | --- |
| Meta Ad Library | Political advertisements, audience composition, spending, impressions, and ad characteristics | No |
| Meta Ad Targeting Dataset | Age and gender targeting information | No |
| Official election records | Candidates, parties, and election information | No |
| PopuList | Classification of populist, far-left, and far-right parties | No |
| Derived analysis data | Intermediate datasets used by the analysis | Where permitted |

Meta Ad Library data can be retrieved at:

https://www.facebook.com/ads/library/

Meta Ad Targeting Dataset documentation is available at:

https://developers.facebook.com/docs/fort-ads-targeting-dataset

The replication material provides the ad IDs needed to retrieve the corresponding advertisements from the Meta Ad Library.

Election information was collected from official national election records. Party classifications are based on the PopuList.

## Computational Requirements

The analysis is implemented in **R**.

Main R packages used include:

`arrow`, `tidyverse`, `lubridate`, `ggrepel`, `MatchIt`, `WeightIt`,
`cobalt`, `marginaleffects`, `lme4`, `broom`, `sandwich`,
`clubSandwich`, `lmtest`, `ggpattern`, `transport`, `furrr`,
`betareg`, `ggeffects`, `sf`, and `car`.

A random seed of `42` is used where applicable.

## Description of Code

- `analysis_ads.Rmd` — data preparation, descriptive analyses, regression models, robustness checks, and figures.
- `utils.R` — helper functions used by the main analysis.

## Instructions to Replicators

1. Install R and the packages listed above.
2. Obtain the required data from the sources described above.
3. Place the required input files in the data directory.
4. Update `path_data` and `path_figures` at the beginning of `analysis_ads.Rmd` if necessary.
5. Run `analysis_ads.Rmd` from top to bottom.

## Figures and Analyses

The code in `analysis_ads.Rmd` reproduces the main analyses and figures reported in the manuscript, including:

| Output | Description |
| --- | --- |
| Figure 1 | Gender-based discrepancies for populist vs. non-populist ads across EU countries |
| Figure 2 | Main regression estimates |
| Figure 3 | Predicted excess male share for populist and non-populist ads |
| Figure 4 | Gendered delivery across the ideological spectrum |
| Figure 5 | Regression estimates for far-left and far-right parties |
| Supplementary analyses | Alternative outcomes, model specifications, sample restrictions, and robustness checks |

[Add the license applying to the code and replication materials.]
