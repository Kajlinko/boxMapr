prependr <- function(x, prefix) {
  if (grepl("^[0-9]", x)) {
    return(paste0(prefix, x))
  }
  # if (is.na(x)) {
  #   return("EMPTY NONE")
  # }
  return(x)
}

prepend_df <- function(df, prefix) {
  df %>%
    mutate(across(everything(), ~ sapply(.x, prependr, prefix)))
}

get_data_from_boxes <- function(box_list) {
  
  samples <- character(length = 0L)
  box_ids <- character(length = 0L)
  box_times <- character(length = 0L)
  
  # all boxes
  for(box in box_list) {
    box <- unlist(box, use.names = FALSE)
    samples <- append(samples, box)
    box_ids <- append(box_ids, stringr::word(box, 1))
    box_times <- append(box_times, stringr::word(box, 2))
  }
  
  box_times[is.na(box_times)] <- "ADM"
  
  box <- data.frame(box_ids, box_times)
  samples <- unique(samples) 
  samples <- na.omit(samples)
  
  widebox <- box %>% tidyr::pivot_wider(names_from = box_times, values_from = box_times)
  
  replace_with_length <- function(df) {
    df %>%
      mutate(across(everything(), ~ sapply(.x, length)))
  }
  
  widebox[,-1] <- replace_with_length(widebox[,-1])
  
  return(list(samples = samples, box_times = unique(box_times), 
              widebox = widebox))
  
}

filter_data <- function(data, pattern) {
  if (pattern == "") {
    return(data)
  } else {
    return(data[str_detect(data$sample, pattern), ])
  }
}

get_element_name <- function(lst, index) {
  if (is.null(names(lst))) {
    return(NULL)
  } else {
    return(names(lst)[index])
  }
}

find_index_in_dfs <- function(lst, target) {
  for (df_index in seq_along(lst)) {
    df <- lst[[df_index]]
    for (row in 1:nrow(df)) {
      for (col in 1:ncol(df)) {
        cell_value <- df[row, col]
        if (is.na(cell_value)) {
          next  # Skip NA values
        }
        if (is.character(cell_value) && cell_value == target) { 
          return(list(box = get_element_name(lst, df_index), row = row, col = col))
        }
      }
    }
  }
  return(NULL)
}

find_indices_in_dfs <- function(lst, target) {
  indices <- list()
  for (df_index in seq_along(lst)) {
    df <- lst[[df_index]]
    for (row in 1:nrow(df)) {
      for (col in 1:ncol(df)) {
        cell_value <- df[row, col]
        if (is.na(cell_value)) {
          next  # Skip NA values
        }
        if (is.character(cell_value) && cell_value == target) {
          indices <- append(indices, list(list(box = get_element_name(lst, df_index), row = row, col = col)))
        }
      }
    }
  }
  return(indices)
}

convert_list_to_df <- function(my_list) {
  purrr::imap_dfr(my_list, ~ {
    tibble(
      sample = .y,
      box = sapply(.x, `[[`, "box"),
      row = sapply(.x, `[[`, "row"),
      col = sapply(.x, `[[`, "col")
    )
  }) %>%
    tidyr::unnest(c(box, row, col))
}

order_df <- function(df) {
  df <- df %>%
    separate(sample, into = c("sample", "timepoint"), sep = " ")
  
  timepoint_order <- c("ADM", "24H", "1M", "6M")
  
  df <- df %>%
    mutate(timepoint = factor(timepoint, 
                              levels = c(timepoint_order, 
                                         setdiff(unique(timepoint), 
                                                 timepoint_order))))
  
  df <- df %>%
    arrange(sample, timepoint)
  
  # Print the resulting dataframe
  return(df)
}
