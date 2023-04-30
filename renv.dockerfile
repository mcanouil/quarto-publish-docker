ARG QUARTO_VERSION="1.4.13"

FROM ghcr.io/quarto-dev/quarto:${QUARTO_VERSION} AS builder

ARG RIG_VERSION="latest"
ARG R_VERSION="release"
COPY install-rig.sh /tmp/install-rig.sh
RUN bash /tmp/install-rig.sh "${RIG_VERSION}"
RUN rig add ${R_VERSION} && Rscript -e 'pak::pkg_install("renv")'

COPY mywebsite-renv /app
WORKDIR /app
RUN Rscript -e 'renv::restore()' && quarto render .

FROM httpd:alpine
COPY --from=builder /app/_site/ /usr/local/apache2/htdocs/
