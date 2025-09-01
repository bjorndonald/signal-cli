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

# Expose port 8085 for Railway
EXPOSE 8085

# Create a startup script
RUN echo '#!/bin/bash\n\
# Wait for account to be configured\n\
if [ ! -f "/var/lib/signal-cli/data/accounts.json" ]; then\n\
    echo "No Signal account configured. Please configure an account first."\n\
    echo "You can use the following commands to set up:"\n\
    echo "1. Register: signal-cli -a +PHONENUMBER register"\n\
    echo "2. Verify: signal-cli -a +PHONENUMBER verify CODE"\n\
    echo "3. Start daemon: signal-cli -a +PHONENUMBER daemon --http 0.0.0.0:8085"\n\
    exit 1\n\
fi\n\
\n\
# Get the first configured account\n\
ACCOUNT=$(cat /var/lib/signal-cli/data/accounts.json | grep -o '"number":"[^"]*"' | head -1 | cut -d'"' -f4)\n\
\n\
if [ -z "$ACCOUNT" ]; then\n\
    echo "No valid account found in configuration"\n\
    exit 1\n\
fi\n\
\n\
echo "Starting signal-cli daemon for account: $ACCOUNT on port 8085"\n\
exec /opt/signal-cli/bin/signal-cli -a "$ACCOUNT" daemon --http 0.0.0.0:8085 --receive-mode=on-start\n\
' > /opt/start.sh && chmod +x /opt/start.sh

USER signal-cli

# Use the startup script as entrypoint
ENTRYPOINT ["/opt/start.sh"]
