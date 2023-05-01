# Publish/Deploy Quarto Documents/Projects as a Docker Container

This repository contains the source code for the Docker image that is used to deploy a Quarto website as a Docker container.

## `renv` (<https://rstudio.github.io/renv/>)

1. Create a website using the Quarto CLI and add a code cell to the `about.qmd` file that uses the `palmerpenguins` R package:

   ```bash
   quarto create-project --type website:blog mywebsite-renv && cd mywebsite-renv || exit
   echo -e '\n```{r}\nlibrary(ggplot2)\nlibrary(palmerpenguins)\nggplot(penguins) +\n  aes(x = bill_length_mm, y = bill_depth_mm) +\n  geom_point(aes(colour = species)) +\n  geom_smooth(method = "lm", se = FALSE)\n```' >> about.qmd
   ```

2. Setup `renv` and snapshot the dependencies in the `_dependencies.R` file (see [`renv` documentation](https://rstudio.github.io/renv/articles/renv.html#snapshotting-dependencies) for more information on snapshotting dependencies):

   ```bash
   echo -e 'library(knitr)\nlibrary(rmarkdown)\nlibrary(ggplot2)\nlibrary(palmerpenguins)' >> _dependencies.R
   Rscript --vanilla -e 'install.packages("renv")' -e "renv::init()"
   Rscript --vanilla -e "renv::hydrate()" -e "renv::snapshot()"
   ```

3. Build the Docker image from the [`Dockerfile`](renv.dockerfile):

   ```bash
   cd ..
   docker buildx build \
     --platform "linux/amd64" \
     --build-arg QUARTO_VERSION=1.4.13 \
     --tag "mywebsite-renv:1.0.0" \
     --file renv.dockerfile .
   ```

4. Deploy locally, push to a Docker registry, or share the image (_i.e._, less than 60 Mb in this case) with others:

   ```bash
   docker container run \
     --detach \
     --platform "linux/amd64" \
     --name my-website-renv \
     --publish 8080:80 \
     mywebsite-renv:1.0.0
   ```

5. View the website at <http://localhost:8080>.

## `pak` (<https://pak.r-lib.org/>)

1. Create a website using the Quarto CLI and add a code cell to the `about.qmd` file that uses the `palmerpenguins` R package:

   ```bash
   quarto create-project --type website:blog mywebsite-pak && cd mywebsite-pak || exit
   echo -e '\n```{r}\nlibrary(ggplot2)\nlibrary(palmerpenguins)\nggplot(penguins) +\n  aes(x = bill_length_mm, y = bill_depth_mm) +\n  geom_point(aes(colour = species)) +\n  geom_smooth(method = "lm", se = FALSE)\n```' >> about.qmd
   ```

2. Setup `pak` `lockfile`(see [`pak` documentation](https://pak.r-lib.org/reference/index.html#lock-files) for more information on snapshotting dependencies):

   ```bash
   Rscript --vanilla -e 'install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/stable/%s/%s/%s", .Platform$pkgType, R.Version()$os, R.Version()$arch))'
   Rscript --vanilla -e 'pak::lockfile_create(c("knitr", "rmarkdown", "ggplot2", "palmerpenguins"))'
   ```

3. Build the Docker image from the [`Dockerfile`](pak.dockerfile):

   ```bash
   cd ..
   docker buildx build \
     --platform "linux/amd64" \
     --build-arg QUARTO_VERSION=1.4.13 \
     --tag "mywebsite-pak:1.0.0" \
     --file pak.dockerfile .
   ```

4. Deploy locally, push to a Docker registry, or share the image (_i.e._, less than 60 Mb in this case) with others:

   ```bash
   docker container run \
     --detach \
     --platform "linux/amd64" \
     --name my-website-pak \
     --publish 8080:80 \
     mywebsite-pak:1.0.0
   ```

5. View the website at <http://localhost:8080>.

## `r2u` (<https://github.com/eddelbuettel/r2u>)

It's also possible to use `r2u` to install R packages,
but it's not compatible with `renv`, `pak`, and `rig`,
so you'll need to install R yourself.
