ARG RSTUDIO_VERSION
FROM rstudio/rstudio-workbench:${RSTUDIO_VERSION}

RUN apt-get update \
 && apt-get install --yes --no-install-recommends \
            libpam-mount \
            # focal and later: libpam-mount-bin \
            cifs-utils \
            ssl-cert \
 && usermod --append --groups ssl-cert rstudio-server \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
