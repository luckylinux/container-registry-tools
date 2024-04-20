FROM debian:latest

ARG TARGETPLATFORM
#ARG BUILDPLATFORM

# RegClient tag
ARG REGCLIENT_TAG="v0.6.0"
#ARG REGCLIENT_TAG="latest"

# Create Directory for App
RUN mkdir -p "/opt"
RUN mkdir -p "/opt/app"

# Change Directory
WORKDIR "/opt/app"

# Copy APP Script
COPY app.sh app.sh

# Change Directory
WORKDIR "/etc"

# Add APT Configuration for more recent (testing) Packages
ADD etc /etc/

# Change Workdir Back to App Folder
WORKDIR "/opt/app"

# Update Sources
RUN apt-get update

# Install skopeo
RUN apt-get install -y skopeo 

# Install other Dependencies / recommended Packages
RUN apt-get install -y ca-certificates bash curl wget

# Clean APT Cache
RUN apt-get clean



# Change Shell
RUN chsh -s /bin/bash root
RUN export SHELL="/bin/bash"
RUN ln -sf /bin/bash /bin/sh

# set ENV to execute startup scripts
ENV ENV /etc/profile

# Set PATH Variable
ENV PATH="/opt/app:$PATH"

# Copy Regclient Installer Script
COPY install-regclient.sh /opt/install-regclient.sh

# RUN Regclient Installer Script
RUN bash -c /opt/install-regclient.sh "${TARGETPLATFORM}" "${REGCLIENT_TAG}"

# Set Path to include RegClient
ENV PATH="/opt/regclient:$PATH"

# Copy and Execute Entrypoint Script
COPY docker-entrypoint.sh /opt/
RUN chmod +x /opt/docker-entrypoint.sh
ENTRYPOINT ["/opt/docker-entrypoint.sh"]
