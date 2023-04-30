#!/usr/bin/env bash

quarto create-project --type website:blog mywebsite-pak && cd mywebsite-pak || exit
echo -e '\n```{r}\nlibrary(ggplot2)\nlibrary(palmerpenguins)\nggplot(penguins) +\n  aes(x = bill_length_mm, y = bill_depth_mm) +\n  geom_point(aes(colour = species)) +\n  geom_smooth(method = "lm", se = FALSE)\n```' >> about.qmd

Rscript -e 'install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/stable/%s/%s/%s", .Platform$pkgType, R.Version()$os, R.Version()$arch))'
Rscript -e 'pak::lockfile_create(c("knitr", "rmarkdown", "ggplot2", "palmerpenguins"))'

cd ..

docker buildx build \
  --platform "linux/amd64" \
  --build-arg QUARTO_VERSION=1.4.13 \
  --tag "mywebsite-pak:1.0.0" \
  --file pak.dockerfile .

docker container run \
  --detach \
  --platform "linux/amd64" \
  --name my-website-pak \
  --publish 8080:80 \
  mywebsite-pak:1.0.0

# http://localhost:8080/
