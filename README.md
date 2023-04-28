# Publish/Deploy Quarto as a Docker Container

This repository contains the source code for the Docker image that is used to deploy a Quarto website as a Docker container.

## Demo

1. Create a website using the Quarto CLI and add a code cell to the `about.qmd` file that uses the `palmerpenguins` R package:

   ```bash
   quarto create-project --type website:blog mywebsite && cd mywebsite || exit
   echo -e '\n```{r}\nlibrary(ggplot2)\nlibrary(palmerpenguins)\nggplot(penguins) +\n  aes(x = bill_length_mm, y = bill_depth_mm) +\n  geom_point(aes(colour = species)) +\n  geom_smooth(method = "lm", se = FALSE)\n```' >> about.qmd
   ```

2. Setup `renv` and snapshot the dependencies:

   ```bash
   echo -e 'library(knitr)\nlibrary(rmarkdown)\nlibrary(ggplot2)\nlibrary(palmerpenguins)' >> _dependencies.R
   Rscript --vanilla -e "renv::init()"
   Rscript --vanilla -e "renv::hydrate()" -e "renv::snapshot()"
   ```

3. Build the Docker image from the [`Dockerfile`](Dockerfile):

   ```bash
   cd ..
   docker buildx build --platform "linux/amd64" --build-arg QUARTO_VERSION=1.4.13 --tag "mywebsite:1.0.0" .
   ````

4. Deploy locally:

   ```bash
   docker container run --detach --platform "linux/amd64" --name my-quarto-website -p 8080:80 mywebsite:1.0.0
   ```

5. View the website at <http://localhost:8080>.
