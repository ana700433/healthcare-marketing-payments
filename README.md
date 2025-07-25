# Healthcare Marketing Payments Analysis

## Overview

This project explores **marketing payments** made by pharmaceutical and medical‐device
manufacturers to physicians across the United States.  The underlying data come
from the [Centers for Medicare & Medicaid Services (CMS) Open Payments program](https://openpaymentsdata.cms.gov/)
which requires industry to disclose payments to health‑care providers.  The
Open Payments summary data used here aggregates general (non‑research) payments
by state and year.  These payments often include food and beverage, travel and
lodging, consulting fees and speaker honoraria, and can serve as a proxy for
marketing spend in the health‑care sector.

The objective of this analysis is to demonstrate business‐analytics skills
by constructing a reproducible R workflow that ingests multiple years of
Open Payments summary data, engineers meaningful metrics (e.g. **payment per
physician**), and generates visualisations that reveal geographic and temporal
patterns in industry marketing activities.  The project culminates in a set of
publication‑quality plots and summary tables suitable for inclusion in a
professional portfolio.

## Project structure

```
HealthcareMarketingPayments/
├── data/                  # Raw CSV files for each program year (2018–2024)
│   ├── payments_2018.csv
│   ├── payments_2019.csv
│   ├── payments_2020.csv
│   ├── payments_2021.csv
│   ├── payments_2022.csv
│   ├── payments_2023.csv
│   └── payments_2024.csv
├── src/                   # Analysis code in R
│   └── analysis.R
├── report/
│   ├── figures/           # Generated plots (PNG files)
│   ├── national_summary.csv
│   └── top_states_per_year.csv
└── README.md              # Project description and usage instructions
```

## Getting the data

The raw datasets were downloaded manually from the “Payments by State” summary
tool on the Open Payments website.  Filters were set to:

* **Record type:** General Payment
* **Recipient type:** Physician
* **Nature of payment:** All Natures of Payments (excluding ownership)
* **Program years:** 2018–2024 (inclusive)

For each year, the **Download data (CSV)** button was clicked and the
resulting file was renamed to `payments_YYYY.csv` and placed in the `data`
directory.  Each CSV includes one row per state (including the District of
Columbia and U.S. territories) with aggregated metrics such as the total
payment amount, the number of physicians receiving payments, the average
payment per physician and the median payment per physician.

Because the data were collected manually, no credentials or API tokens are
required to reproduce this analysis.  Should CMS change the interface in
future years, you can search the Open Payments site for “summary by state”
and use the download functionality to obtain updated CSV files.

## Requirements

To run the analysis script you need:

* R (version 3.6 or later)
* The `tidyverse` package for data manipulation and plotting
* Optionally, the `maps` package if you wish to generate the U.S. choropleth
  map (the script will skip the map if the package is not installed)

You can install the required packages from CRAN:

```r
install.packages(c("tidyverse", "maps"))
```

## Running the analysis

Open a terminal and set your working directory to the `src` folder:

```bash
cd HealthcareMarketingPayments/src
Rscript analysis.R
```

The script will read all CSV files from the `data` directory, combine them,
compute summary statistics and generate several plots.  Output files are
written to the `report` directory:

* `national_summary.csv` – national totals and per‑physician averages by year
* `top_states_per_year.csv` – the five states with the highest payment per
  physician for each year
* `figures/national_total_payment_trend.png` – line chart of total payment by year
* `figures/avg_payment_per_physician_trend.png` – line chart of average payment per physician
* `figures/top10_states_2024.png` – bar chart of the top ten states by total payment in 2024
* `figures/payment_per_physician_map_2024.png` – heat map of payment per physician by state (requires the `maps` package)

If the `maps` package is not installed, the script will issue a warning and
skip generating the choropleth map.

## Analytical questions addressed

1. **How has marketing spend evolved over time?**  The national summary tables
   and line charts show how total payments and per‑physician averages have
   changed from 2018 through 2024.  Business analysts can use these trends to
   evaluate whether regulations or market forces are reducing or increasing
   physician‑directed marketing.
2. **Which states receive the most marketing dollars?**  The top‐10 bar chart
   highlights where the largest volumes of payments are concentrated in the
   latest year (2024).  Analysts may correlate these findings with state
   population size, prescribing patterns or policy environments.
3. **Where are payments most intensive on a per‑physician basis?**  The
   `top_states_per_year.csv` table and the choropleth map display how much
   industry spends per physician in each state, revealing outliers where
   marketing activity is particularly high relative to the number of
   physicians.

## Why this project is unique

While many portfolio projects focus on retail sales, e‑commerce or public
transportation data, this project examines a **regulatory compliance dataset
that captures the intersection of health care and marketing**.  By analysing
Open Payments summary data, the project demonstrates:

* **Domain awareness:** an understanding of how marketing interactions between
  industry and clinicians are recorded and disclosed, and why these
  interactions matter for health‐care cost and quality.
* **Data wrangling of lightly documented data:** dealing with manual
  downloads, non‑standard file naming conventions and aggregated metrics.
* **Storytelling with geographic and temporal trends:** using line charts,
  bar charts and maps to communicate insights at multiple levels of
  granularity.

Together, these skills showcase versatility and attention to ethical issues in
data analysis—qualities that are valuable to prospective employers.
