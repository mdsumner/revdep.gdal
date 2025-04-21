packages_to_revdep <- function() {
  c( "terra", "sf", "gdalraster", "vapour", "gdalcubes")
}


get_packages <- function() {
  chk <- try({
  workingdir <- "_revdepbuild"
  pkgdir <- "_revdeppkg"
  if (fs::dir_exists(workingdir)) fs::dir_delete(workingdir)
  fs::dir_create(workingdir)
  if (fs::dir_exists(pkgdir)) fs::dir_delete(pkgdir)
  fs::dir_create(pkgdir)


  a <- download.packages(packages_to_revdep(), destdir = pkgdir)
  paths <- a[,2, drop = TRUE]
  for (i in seq_along(paths)) p <- untar(paths[i], exdir = workingdir)
})
  if (inherits(chk, "try-error")) return(NULL)
  paths
}
.num_workers <- function() {
  if (Sys.info()["nodename"] %in% c("marinepredators")) {
    return(31L)
  } else {
    return(4L)
  }
}
revdep <- function() {
  get_packages()
  workingdir <- "_revdepbuild"
  pkgs <- fs::dir_ls(workingdir)
  pkgs <- pkgs[fs::is_dir(pkgs)]

  for (i in seq_along(pkgs)) {
    chk <- revdepcheck::revdep_check(pkgs[i], num_workers = .num_workers())
  }
}

cleanup <- function() {
  f <- fs::dir_ls(regexp = "_revdepbuild", recurse = T, type  = "f")
 ok <- file.path("revdep", c("cran.md", "data.sqlite", "failures.md", "problems.md", "README.md")  )
  keep <- unlist(lapply(ok, \(.x) grep(.x, f, value = TRUE)))
  todelete <- setdiff(f, keep)
  todelete <- todelete[fs::file_exists(todelete)]
 for (i in seq_along(todelete)) try(fs::file_delete(todelete[i]))

}
