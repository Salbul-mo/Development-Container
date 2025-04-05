# FROM: Specify the base image (RockyLinux 9.5 in this case).
FROM rockylinux/rockylinux:9.5

# Update and install essential packages
# - dnf is used to update and install required libraries and tools.
# - "sudo", "vim", "curl", etc., are installed to help with development tasks.
RUN dnf clean all && \
    dnf update -y --best --allowerasing && \
    dnf install -y sudo epel-release dnf-plugins-core && \
    dnf config-manager --set-enabled crb && \
    dnf groupinstall -y "Development Tools" && \
    dnf install -y \
    net-tools wget curl vim nano unzip tar git lsof tmux \
    java-17-openjdk-devel nginx supervisor ca-certificates \
    --best --allowerasing && \
    dnf module reset nodejs -y && \
    dnf module enable -y nodejs:22 && \
    dnf install -y nodejs && \
    dnf clean all && \
    rm -rf /var/cache/dnf/*

# # ARG: Define build-time variables for Gradle installation.
#ARG GRADLE_VERSION
#ARG GRADLE_HOME

# # Install SDKMAN and Gradle using provided build arguments.
# RUN curl -s "https://get.sdkman.io" | bash && \
#     bash -c "source \$HOME/.sdkman/bin/sdkman-init.sh && \
#     sdk install gradle \${GRADLE_VERSION}"

# # Set environment variables for Gradle. This allows tools to find Gradle.
# ENV GRADLE_VERSION=\${GRADLE_VERSION}
# ENV GRADLE_HOME=\${GRADLE_HOME}
# ENV PATH=\$PATH:\${GRADLE_HOME}/bin

# ARG: Define build-time variables for Maven installation.
# ARG MAVEN_VERSION
# ARG MAVEN_HOME

# # Install Maven by downloading and extracting it, then linking the mvn binary.
# RUN curl -fsSL https://dlcdn.apache.org/maven/maven-3/\${MAVEN_VERSION}/binaries/apache-maven-\${MAVEN_VERSION}-bin.tar.gz -o /tmp/apache-maven.tar.gz && \
#     tar -xzf /tmp/apache-maven.tar.gz -C /usr/share && \
#     mv /usr/share/apache-maven-\${MAVEN_VERSION} \${MAVEN_HOME} && \
#     ln -s \${MAVEN_HOME}/bin/mvn /usr/bin/mvn && \
#     rm -f /tmp/apache-maven.tar.gz

# # Set environment variables for Maven.
# ENV MAVEN_HOME=\${MAVEN_HOME}
# ENV PATH=\$PATH:\${MAVEN_HOME}/bin

# # Install FFmpeg for multimedia handling.
# RUN dnf -y install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-9.noarch.rpm && \
#     dnf makecache && \
#     dnf -y install ffmpeg --best --allowerasing && \
#     dnf clean all && \
#     rm -rf /var/cache/dnf/*

# Install Docker inside the container (if needed for running sibling containers or Docker-in-Docker scenarios).
RUN dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
    dnf install -y docker-ce docker-ce-cli containerd.io --best --allowerasing && \
    dnf update -y --best --allowerasing && \
    dnf clean all

# Install MariaDB client (server not required here since we'll run the DB in a separate container).
RUN dnf install -y mariadb && \
    dnf clean all

# ARG: Variables to set up a new user for development.
ARG DEV_USER_PASSWORD
ARG DEV_USER_NAME
ARG DEV_USER_GROUP
# Add a new user, set password, group and add to docker group.
RUN adduser ${DEV_USER_NAME} && \
    echo "${DEV_USER_NAME}:${DEV_USER_PASSWORD}" | chpasswd && \
    usermod -aG ${DEV_USER_GROUP} ${DEV_USER_NAME} && \
    usermod -s /bin/bash ${DEV_USER_NAME} && \
    usermod -aG docker ${DEV_USER_NAME}

# Setup directories, change ownership for workspace and log directories.
RUN mkdir -p /home/workspace /var/log && \
    chown -R ${DEV_USER_NAME}:${DEV_USER_GROUP} /home/workspace /var/log

# SECURITY: Clear sensitive build ARGs
ENV DEV_USER_PASSWORD=""

# Set the working directory to the user's workspace.
WORKDIR /home/workspace

# Copy supervisord configuration to properly manage processes.
COPY --chown=root:root supervisord.conf /etc/supervisord.conf
RUN chmod 644 /etc/supervisord.conf

# # SECURITY: Add security hardening profile/limits
# RUN echo "* hard core 0" >> /etc/security/limits.conf && \
#     echo "* soft nproc 1024" >> /etc/security/limits.conf && \
#     echo "* hard nproc 2048" >> /etc/security/limits.conf

# # SECURITY: Apply recommended sysctl settings
# RUN echo "kernel.dmesg_restrict=1" >> /etc/sysctl.conf && \
#     echo "kernel.kptr_restrict=2" >> /etc/sysctl.conf && \
#     echo "net.ipv4.conf.all.log_martians=1" >> /etc/sysctl.conf && \
#     echo "net.ipv4.conf.default.log_martians=1" >> /etc/sysctl.conf

# SECURITY: Switch to non-root user for the main process
# USER \${DEV_USER_NAME}

# # SECURITY: Set secure umask to ensure newly created files have restrictive permissions
# RUN echo "umask 027" >> ~/.bashrc

# Final command to run supervisord as the container's entrypoint.
# Switch back to root only for the entrypoint (supervisord manages permissions internally)
# USER root
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]