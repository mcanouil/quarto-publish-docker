#!/usr/bin/env bash

quarto create-project --type website:blog mywebsite-renv && cd mywebsite-renv || exit
echo -e '\n```{r}\nlibrary(ggplot2)\nlibrary(palmerpenguins)\nggplot(penguins) +\n  aes(x = bill_length_mm, y = bill_depth_mm) +\n  geom_point(aes(colour = species)) +\n  geom_smooth(method = "lm", se = FALSE)\n```' >> about.qmd

echo -e 'library(knitr)\nlibrary(rmarkdown)\nlibrary(ggplot2)\nlibrary(palmerpenguins)' >> _dependencies.R
Rscript -e 'install.packages("renv")' -e "renv::init()"
Rscript -e "renv::hydrate()" -e "renv::snapshot()"

cd ..

docker buildx build \
  --platform "linux/amd64" \
  --build-arg QUARTO_VERSION=1.4.13 \
  --tag "mywebsite-renv:1.0.0" \
  --file renv.dockerfile .

docker container run \
  --detach \
  --platform "linux/amd64" \
  --name my-website-renv \
  --publish 8080:80 \
  mywebsite-renv:1.0.0

# http://localhost:8080/
