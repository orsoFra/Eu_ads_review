
# Extract coefficients with inference (incl. 95% and 99% CI) from coeftest object
extract_coef_inference <- function(coeftest_obj){
  coef_df <- broom::tidy(coeftest_obj, conf.level = 0.95, conf.int = TRUE) %>%
    rename("conf.low.95" = "conf.low", "conf.high.95" = "conf.high") %>%
    cbind(broom::tidy(coeftest_obj, conf.level = 0.99, conf.int = T, .id = "model")[, c("conf.low", "conf.high")]) %>%
    rename("conf.low.99" = "conf.low", "conf.high.99" = "conf.high")
  
  return(coef_df)
}

# Estimate linear model for each country separately
estimate_country <- function(data, country_code, dep_var, indep_vars, vcov_type = "HC1"){
  
  # Filter data by country
  df <- data %>% 
    filter(country == country_code) %>%
    droplevels()
    
  if (nrow(df) == 0){
    return(NULL)
  }
  
  # Check each independent variable that’s a factor
  for (var in indep_vars) {
    if (is.factor(df[[var]]) && length(levels(df[[var]])) < 2) {
      return(NULL)
    } else if (is.character(df[[var]]) && length(unique(df[[var]])) < 2) {
      return(NULL)
    }
  }
  
  # Define formulat
  formula_by_country <- as.formula(str_c(dep_var, " ~ ", paste(indep_vars, collapse = " + ")))
  
  # Estimate linear model
  lm <- lm(formula_by_country, data = df)
  
  # Robust inference
  inference <- coeftest(lm, vcov = vcovCL(lm, cluster = ~ national_party, type = vcov_type, cadjust = TRUE))
  
  # Clean regression results
  coef_df <- broom::tidy(inference, conf.level = 0.95, conf.int = TRUE) %>%
    rename("conf.low.95" = "conf.low", "conf.high.95" = "conf.high") %>%
    cbind(broom::tidy(inference, conf.level = 0.99, conf.int = T, .id = "model")[, c("conf.low", "conf.high")]) %>%
    rename("conf.low.99" = "conf.low", "conf.high.99" = "conf.high") %>%
    mutate(country = country_code)
  
  # Create list with results
  output <- list(
    lm = lm,
    inference = inference,
    coef_df = coef_df
  )
  
  return(output)
}

# Perform propensity score matching
perform_psm <- function(data, balancing_vars, treatment_var, outcome_var, psm_method = "quick"){
  
  # Handle missing values
  data <- data %>%
    filter(complete.cases(select(., all_of(balancing_vars), all_of(treatment_var), all_of(outcome_var))))
  
  # Check number of populist and non-populist ads
  data %>%
    group_by(!!sym(treatment_var)) %>%
    summarize(n_ads = n())
  
  # Raise error if there are no (non)populist ads
  if(nrow(filter(data, !!sym(treatment_var) == "Non-populist")) == 0 | nrow(filter(data, !!sym(treatment_var) == "Populist")) == 0){
    stop("There are no (non)populist ads in the data.")
  }
  
  # Propensity score matching
  match.out.psm <- matchit(
    formula = as.formula(str_c(treatment_var, " ~ ", paste(balancing_vars, collapse = " + "))),
    data = data, 
    method = psm_method)
  
  # Diagnostics
  balancing_tab <- summary(match.out.psm)
  
  # Extract matched data
  matched_data <- match_data(match.out.psm)
  
  # Run regression model
  formula_adj <- as.formula(str_c(outcome_var, " ~ ", treatment_var, " * ", "(", paste(balancing_vars, collapse = " + "), ")"))
  lm_model_adj <- lm(formula_adj, data = matched_data, weights = weights)
  
  # G-Computation for treatment effect
  if (psm_method %in% c("quick", "full")){
    ATE <- avg_comparisons(lm_model_adj, variables = treatment_var, vcov = "HC0")
  } else {
    warning("ATE cannot be computed for this PSM method.")
  }
  
  # Return results
  output <- list(
    match_out = match.out.psm,
    balancing_tab = balancing_tab,
    matched_data = matched_data,
    lm_model_adj = lm_model_adj,
    ATE = ATE
  )
  
  return(output)
}