FROM yutaronishiyama/riscv-chisel-book

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    unzip \
    git \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install run-non-root
ADD https://raw.githubusercontent.com/creemama/run-non-root/master/run-non-root.sh /usr/local/bin/run-non-root
RUN chmod +rx /usr/local/bin/run-non-root

# Install su-exec
RUN cd /tmp; curl -L https://github.com/ncopa/su-exec/archive/dddd1567b7c76365e1e0aac561287975020a8fad.zip -o su-exec.zip \
    && unzip su-exec.zip \
    && cd su-exec-dddd1567b7c76365e1e0aac561287975020a8fad \
    && make \
    && mv su-exec /usr/local/bin \
    && rm -rf /tmp/su-exec-dddd1567b7c76365e1e0aac561287975020a8fad

WORKDIR /src
ENTRYPOINT ["/usr/local/bin/run-non-root"]
