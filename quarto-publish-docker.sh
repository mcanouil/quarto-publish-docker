#!/usr/bin/env bash

quarto create-project --type website:blog mywebsite && cd mywebsite || exit
echo -e '\n```{r}\nlibrary(ggplot2)\nlibrary(palmerpenguins)\nggplot(penguins) +\n  aes(x = bill_length_mm, y = bill_depth_mm) +\n  geom_point(aes(colour = species)) +\n  geom_smooth(method = "lm", se = FALSE)\n```' >> about.qmd
echo -e 'library(knitr)\nlibrary(rmarkdown)\nlibrary(ggplot2)\nlibrary(palmerpenguins)' >> _dependencies.R
Rscript --vanilla -e "renv::init()"
Rscript --vanilla -e "renv::hydrate()" -e "renv::snapshot()"

cd ..

docker buildx build --platform "linux/amd64" --build-arg QUARTO_VERSION=1.4.13 --tag "mywebsite:1.0.0" .

docker container run --detach --platform "linux/amd64" --name my-quarto-website -p 8080:80 mywebsite:1.0.0
# http://localhost:8080/
