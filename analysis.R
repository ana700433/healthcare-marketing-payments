## Healthcare Marketing Payments Analysis
##
## This script reads aggregated Open Payments summary data for general payments to
## physicians from 2018–2024, combines the annual datasets, computes useful
## summary statistics and generates a series of exploratory plots.  These plots
## illustrate trends in industry marketing spend directed toward physicians
## across states and years.  To run this script you will need the `tidyverse`
## package installed.  You can install it from CRAN via
## `install.packages("tidyverse")`.

library(tidyverse)

#-------------------------------------------------------------------------------
# 1. Read and combine the annual datasets
#-------------------------------------------------------------------------------

# Data files are stored in the sibling 'data' directory.  Each file is named
# `payments_YYYY.csv` where YYYY is the program year.  Use list.files to
# dynamically read all of them.
data_dir <- file.path("..", "data")
file_list <- list.files(data_dir, pattern = "^payments_\\d{4}\\.csv$", full.names = TRUE)

payments_list <- lapply(file_list, function(f) {
  df <- readr::read_csv(f, col_types = cols())
  return(df)
})

# Bind the individual data frames into one large table.  The `Program_Year`
# column identifies the year associated with each row.
payments_raw <- bind_rows(payments_list)

#-------------------------------------------------------------------------------
# 2. Data cleaning and feature engineering
#-------------------------------------------------------------------------------

payments <- payments_raw %>%
  # Ensure that Program_Year is stored as an integer
  mutate(Program_Year = as.integer(Program_Year)) %>%
  # Replace missing physician counts with NA_real_ to avoid dividing by zero
  mutate(Total_Number_of_Physicians = if_else(
    Total_Number_of_Physicians == 0, NA_real_, as.double(Total_Number_of_Physicians)
  )) %>%
  # Compute the mean payment amount per physician at the state/year level
  mutate(
    Payment_Per_Physician = Total_Payment_Amount_Physician / Total_Number_of_Physicians
  )

#-------------------------------------------------------------------------------
# 3. National summary statistics
#-------------------------------------------------------------------------------

# Aggregate payments across all states for each year.  The national
# totals provide insight into whether industry marketing spend is
# increasing or decreasing over time.
national_summary <- payments %>%
  group_by(Program_Year) %>%
  summarise(
    National_Total_Payment = sum(Total_Payment_Amount_Physician, na.rm = TRUE),
    Total_Physicians = sum(Total_Number_of_Physicians, na.rm = TRUE),
    Avg_Payment_Per_Physician = National_Total_Payment / Total_Physicians
  ) %>%
  arrange(Program_Year)

#-------------------------------------------------------------------------------
# 4. Top states by payment metrics
#-------------------------------------------------------------------------------

# For each year, identify the five states with the highest average payment per
# physician.  This gives a sense of regional concentration of marketing spend.
top_states_per_year <- payments %>%
  group_by(Program_Year) %>%
  arrange(desc(Payment_Per_Physician)) %>%
  slice_head(n = 5) %>%
  ungroup()

# Identify the top 10 states by total payment amount in 2024.  This will be
# visualised as a horizontal bar chart.
top10_2024 <- payments %>%
  filter(Program_Year == 2024) %>%
  arrange(desc(Total_Payment_Amount_Physician)) %>%
  slice_head(n = 10) %>%
  mutate(State_Name = fct_reorder(State_Name, Total_Payment_Amount_Physician))

#-------------------------------------------------------------------------------
# 5. Create plots
#-------------------------------------------------------------------------------

## Create output directory for plots
plot_dir <- file.path("..", "report", "figures")
if (!dir.exists(plot_dir)) dir.create(plot_dir, recursive = TRUE)

# 5.1 National total payment trend
p1 <- ggplot(national_summary, aes(x = Program_Year, y = National_Total_Payment / 1e6)) +
  geom_line(color = "steelblue", size = 1) +
  geom_point(color = "steelblue", size = 2) +
  labs(
    title = "National Total Marketing Payment to Physicians (2018–2024)",
    x = "Program Year",
    y = "Total Payment (Millions USD)"
  ) +
  theme_minimal()

ggsave(filename = file.path(plot_dir, "national_total_payment_trend.png"), plot = p1, width = 8, height = 4)

# 5.2 National average payment per physician trend
p2 <- ggplot(national_summary, aes(x = Program_Year, y = Avg_Payment_Per_Physician)) +
  geom_line(color = "darkgreen", size = 1) +
  geom_point(color = "darkgreen", size = 2) +
  labs(
    title = "Average Marketing Payment per Physician (2018–2024)",
    x = "Program Year",
    y = "Average Payment per Physician (USD)"
  ) +
  theme_minimal()

ggsave(filename = file.path(plot_dir, "avg_payment_per_physician_trend.png"), plot = p2, width = 8, height = 4)

# 5.3 Top 10 states by total payment amount in 2024
p3 <- ggplot(top10_2024, aes(x = State_Name, y = Total_Payment_Amount_Physician / 1e6)) +
  geom_col(fill = "#1f77b4") +
  coord_flip() +
  labs(
    title = "Top 10 States by Total Marketing Payment to Physicians (2024)",
    x = "State",
    y = "Total Payment (Millions USD)"
  ) +
  theme_minimal()

ggsave(filename = file.path(plot_dir, "top10_states_2024.png"), plot = p3, width = 8, height = 5)

# 5.4 Heat map of payment per physician for 2024

# To create a choropleth map we need to join the summary table with a spatial
# representation of the U.S. states.  This requires the `maps` package.
if (requireNamespace("maps", quietly = TRUE)) {
  us_map <- maps::map_data("state")
  state_summary_2024 <- payments %>%
    filter(Program_Year == 2024) %>%
    mutate(region = tolower(State_Name))
  map_data_2024 <- dplyr::left_join(us_map, state_summary_2024, by = "region")

  p4 <- ggplot(map_data_2024, aes(x = long, y = lat, group = group, fill = Payment_Per_Physician)) +
    geom_polygon(color = "white", size = 0.2) +
    coord_fixed(1.3) +
    scale_fill_viridis_c(option = "plasma", na.value = "grey90") +
    labs(
      title = "Average Marketing Payment per Physician by State (2024)",
      fill = "Payment per Physician (USD)"
    ) +
    theme_void()

  ggsave(filename = file.path(plot_dir, "payment_per_physician_map_2024.png"), plot = p4, width = 9, height = 6)
} else {
  warning("The 'maps' package is not installed. Skipping the choropleth map.")
}

#-------------------------------------------------------------------------------
# 6. Export summary tables
#-------------------------------------------------------------------------------

# Write the national summary and top states tables to CSV for later use.
readr::write_csv(national_summary, file.path("..", "report", "national_summary.csv"))
readr::write_csv(top_states_per_year, file.path("..", "report", "top_states_per_year.csv"))

cat("Analysis complete.  Summary tables and figures have been written to the 'report' directory.\n")
