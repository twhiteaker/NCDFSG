#'@title Check NetCDF-DSG File
#'
#'
#'@param nc A open ncdf4 object.
#'
#'@description
#'Introspects a netcdf file and tries to interpret it as a NetCDF-DSG file. Returns a named
#'\code{list} containing \code{instance_id} \code{instanceDim} \code{node_count}
#'\code{part_node_count} \code{part_type} If these values aren't found or aren't applicable,
#'they are returned \code{NULL}.
#'
#'@references
#'https://github.com/bekozi/netCDF-CF-simple-geometry
#'
#'@importFrom ncdf4 ncatt_get
#'
#'@export
checkNCDF <- function(nc) {

  instance_id<-NULL
  instanceDim<-NULL
  geom_container <- list(geom_type = NULL, node_count = NULL, part_node_count = NULL,
                         part_type = NULL, x = NULL, y = NULL)

  # Check important global atts
  if(!grepl('CF',ncatt_get(nc,0,'Conventions')$value)) {
    warning('File does not advertise CF conventions, unexpected behavior may result.')}

  geom_container_var<-findVarByAtt(nc, pkg.env$geom_type_attr_name, strict = FALSE)
  if(length(geom_container_var) > 1) {
    stop("only one geometry container per file supported")
  } else if(length(geom_container_var) == 0) {
    stop("Didn't find a geometry type attribute, nothing to do.")
  } else {
    geom_container_var <- geom_container_var[[1]]

    geom_container$geom_type <- ncatt_get(nc, geom_container_var, pkg.env$geom_type_attr_name)$value

    geom_container$node_count <- ncatt_get(nc, geom_container_var, pkg.env$node_count_attr_name)$value

    geom_container$part_node_count <- ncatt_get(nc, geom_container_var, pkg.env$part_node_count_attr_name)$value

    geom_container$part_type <- ncatt_get(nc, geom_container_var, pkg.env$part_type_attr_name)$value

    node_coordinates <- strsplit(ncatt_get(nc, geom_container_var, pkg.env$node_coordinates)$value, " ")[[1]]

    for(v in node_coordinates) {
      att <- ncatt_get(nc, v, "cf_role")
      if(att$hasatt) {
        if(att$value == pkg.env$x_cf_role) {
          geom_container$x <- v
        } else if(att$value == pkg.env$y_cf_role) {
          geom_container$y <- v
        } else {
          stop(paste("unexpected cf_role attribute", pkg.env$x_cf_role, "and", pkg.env$y_cf_role, "are allowed."))
        }
      }
    }
  }

  # Look for variable with the timeseries_id in it.
  instance_id<-list()
  instance_id<-append(instance_id, findVarByAtt(nc, 'cf_role', 'timeseries_id'))

  instance_id<-unlist(unique(instance_id))
  if(length(instance_id)>1) { stop('multiple timeseries id variables were found.') }

  if(geom_container$node_count == 0) {
    instanceDim <- nc$var[geom_container$x][[1]]$dim[[1]]$name
  } else {
    instanceDim <- nc$var[geom_container$node_count][[1]]$dim[[1]]$name }

  return(list(instance_id = instance_id,
              instanceDim = instanceDim,
              geom_container = geom_container))
}

findVarByAtt <- function(nc, attribute, value = "*", strict = TRUE) {
  foundVar<-list()
  for(variable in c(names(nc$var), names(nc$dim))) {
    temp<-try(ncatt_get(nc,variable,attribute))
    if(strict) value<-paste0("^",value,"$")
    if(!is.null(temp$hasatt) && temp$hasatt && grepl(value,temp$value)) {
      foundVar<-append(foundVar,variable)
    }
  }
  return(foundVar)
}
