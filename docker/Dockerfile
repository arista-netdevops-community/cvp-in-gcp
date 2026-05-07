FROM ubuntu:20.04

RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    openssh-client \
    python3-pip \
    unzip \
  && rm -rf /var/lib/apt/lists/*

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y \
  && apt-get install google-cloud-sdk -y \
  && rm -rf /var/lib/apt/lists/*

RUN curl https://releases.hashicorp.com/terraform/0.15.1/terraform_0.15.1_linux_amd64.zip -o /tmp/terraform.zip \
  && unzip /tmp/terraform.zip -d /usr/bin \
  && rm -f /tmp/terraform.zip

RUN pip3 install ansible

COPY docker/entrypoint.sh /entrypoint
RUN chmod +x /entrypoint

RUN mkdir /cvp
WORKDIR /cvp
ENTRYPOINT ["/entrypoint"]