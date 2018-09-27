    cranlist <- c("devtools", "data.table",
                    "RPostgreSQL", "sqldf", "gdtools",
                    "JuniperKernel")

    githublist <- c("IRkernel/IRkernel")

    ## cran packages
    for (package in cranlist)
    { 
        if (!require(package, character.only = T, quietly = T))
        {
            install.packages(package)
        }
    }

    ## install IR kernel
    if (!require('IRkernel', character.only = T, quietly = T)) {
        devtools::install_github('IRkernel/IRkernel')
        IRkernel::installspec(user = FALSE)
    }

