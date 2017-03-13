pkg.env <- new.env()
pkg.env$multi_val <- -1
pkg.env$hole_val <- -2

# Arbitrary dim and variable names assumed in code.
pkg.env$node_dim_name <- 'node'
pkg.env$part_dim_name <- 'part'
pkg.env$part_node_count_var_name <- 'part_node_count'
pkg.env$part_type_var_name <- 'part_type'
pkg.env$node_count_var_name <- 'node_count'
pkg.env$geom_container_var_name <- 'geom_container'

# Variables prescribed in the specification.
pkg.env$cf_version <- "CF-1.8"
pkg.env$x_cf_role <- "geometry_x_node"
pkg.env$y_cf_role <- "geometry_y_node"
pkg.env$node_coordinates <- "node_coordinates"
pkg.env$geom_type_attr_name <- "geom_type"
pkg.env$node_count_attr_name <- "node_count"
pkg.env$part_node_count_attr_name <- "part_node_count"
pkg.env$part_type_attr_name <- 'part_type'