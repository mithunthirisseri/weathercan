# Steps/Commands to run before a CRAN release -----------------------------

## Check if version is appropriate
# http://shiny.andyteucher.ca/shinyapps/rver-deps/

## Internal data files
source("data-raw/data-raw.R")
source("data-raw/data-index.R")

## Documentation

# Update NEWS

# Update README.Rmd
# Compile README.md
# REBUILD!
rmarkdown::render("README.Rmd")

# Update cran-comments

# Check spelling
dict <- hunspell::dictionary('en_CA')
devtools::spell_check()
spelling::update_wordlist()

## Finalize package version
v <- "0.3.3"

## Checks
devtools::check()     # Local

# Win builder
devtools::check_win_release() #   <------------
devtools::check_win_devel()
devtools::check_win_oldrelease()

# Build package to check on Rhub and locally
system("cd ..; R CMD build weathercan")

rhub::check_for_cran(path = paste0("../weathercan_", v, ".tar.gz"),
                     check_args = "--as-cran --run-donttest",
                     platforms = c("windows-x86_64-oldrel",
                                   "windows-x86_64-devel",
                                   "windows-x86_64-release"),
                     show_status = FALSE)

# rhub::check_for_cran(path = paste0("../weathercan_", v, ".tar.gz"),
#                      check_args = "--as-cran",
#                      platforms = "solaris-x86-patched",
#                      env_vars = c("_R_CHECK_FORCE_SUGGESTS_" = "false"),
#                      show_status = FALSE)

rhub::check_for_cran(path = paste0("../weathercan_", v, ".tar.gz"),
                     check_args = "--as-cran",
                     platforms = c("fedora-clang-devel", "fedora-gcc-devel"),
                     env_vars = c("_R_CHECK_FORCE_SUGGESTS_" = "false"),
                     show_status = FALSE)

system(paste0("cd ..; R CMD check weathercan_", v, ".tar.gz --as-cran --run-donttest")) # Local

# Problems with latex, open weathercan-manual.tex and compile to get actual errors
# Re-try (skip tests for speed)
#system("cd ..; R CMD check weathercan_0.3.0.tar.gz --as-cran --no-tests")

## Push to github
## Check travis / appveyor

## Check Reverse Dependencies (are there any?)
tools::dependsOnPkgs("weathercan")
devtools::revdep()
revdepcheck::revdep_check()


## Update codemeta
codemetar::write_codemeta()


## Build site (so website uses newest version
## Update website
pkgdown::build_articles(lazy = FALSE)
pkgdown::build_home()
pkgdown::build_news()
pkgdown::build_reference()
pkgdown::build_site(lazy = TRUE)
unlink("./vignettes/normals_cache/", recursive = TRUE)
## Push to github

## CHECK FOR SECURITY VULNERABILITIES!


## Actually release it (SEND TO CRAN!)
devtools::release()

## Once it is released (Accepted by CRAN) create signed release on github
system("git tag -s v0.3.3 -m 'v0.3.3'")
system("git push --tags")
