FROM docker.io/azul/zulu-openjdk:21-jre-headless

LABEL org.opencontainers.image.source=https://github.com/AsamK/signal-cli
LABEL org.opencontainers.image.description="signal-cli provides an unofficial commandline, dbus and JSON-RPC interface for the Signal messenger."
LABEL org.opencontainers.image.licenses=GPL-3.0-only

# Install required packages and create user
RUN apt-get update && \
    apt-get install -y unzip && \
    rm -rf /var/lib/apt/lists/* && \
    useradd signal-cli --system --create-home --home-dir /var/lib/signal-cli

# Add the signal-cli distribution
ADD build/install/signal-cli /opt/signal-cli

# Extract native libraries from libsignal-client JAR
RUN cd /opt/signal-cli/lib && \
    unzip -j libsignal-client-*.jar 'libsignal_jni_amd64.so' -d /usr/lib/ && \
    ln -s /usr/lib/libsignal_jni_amd64.so /usr/lib/libsignal_jni.so && \
    chmod 755 /usr/lib/*.so

# Set library path
ENV LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH

USER signal-cli
ENTRYPOINT ["/opt/signal-cli/bin/signal-cli", "--config=/var/lib/signal-cli"]