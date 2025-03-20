FROM rockylinux/rockylinux:9.5

# 패키지 업데이트 및 필수 패키지 설치
RUN dnf clean all && \
    dnf update -y --best --allowerasing && \
    dnf install -y sudo epel-release dnf-plugins-core && \
    dnf groupinstall -y "Development Tools" && \
    dnf install -y \
    gcc gcc-c++ make cmake automake autoconf \
    kernel-devel kernel-headers elfutils-libelf-devel \
    net-tools wget curl vim nano unzip tar git lsof \
    java-17-openjdk-devel nodejs nginx supervisor \
    --best --allowerasing && \
    dnf module reset nodejs && \
    dnf module enable -y nodejs:18 && \
    dnf config-manager --set-enabled crb && \
    dnf clean all && \
    rm -rf /var/cache/dnf/*

ARG GRADLE_VERSION
ARG GRADLE_HOME
    
# SDKMAN 설치, 초기화 및 gradle 설치
RUN curl -s "https://get.sdkman.io" | bash && \
    bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && \
    sdk install gradle ${GRADLE_VERSION}"

# Set environment variables
ENV GRADLE_VERSION=${GRADLE_VERSION}
ENV GRADLE_HOME=${GRADLE_HOME}
ENV PATH=$PATH:${GRADLE_HOME}/bin


ARG MAVEN_VERSION
ARG MAVEN_HOME

# Maven 설치
RUN curl -fsSL https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz -o /tmp/apache-maven.tar.gz && \
    tar -xzf /tmp/apache-maven.tar.gz -C /usr/share && \
    mv /usr/share/apache-maven-${MAVEN_VERSION} ${MAVEN_HOME} && \
    ln -s ${MAVEN_HOME}/bin/mvn /usr/bin/mvn && \
    rm -f /tmp/apache-maven.tar.gz

# Environment variables for Maven
ENV MAVEN_HOME=${MAVEN_HOME}
ENV PATH=$PATH:${MAVEN_HOME}/bin

# FFmpeg 설치
RUN dnf -y install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-9.noarch.rpm && \
    dnf makecache && \
    dnf -y install ffmpeg --best --allowerasing && \
    dnf clean all && \
    rm -rf /var/cache/dnf/*

# Docker 설치
RUN dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
    dnf install -y docker-ce docker-ce-cli containerd.io --best --allowerasing && \
    dnf update -y --best --allowerasing && \
    dnf clean all

# MYSQL 설치
RUN dnf install -y mysql-server --best --allowerasing && \
    dnf clean all

# 사용자 추가 및 비밀번호 설정
ARG USER_PASSWORD
ARG USER_NAME
ARG USER_GROUP
RUN adduser ${USER_NAME} && \
    echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd && \
    usermod -aG ${USER_GROUP} ${USER_NAME} && \
    usermod -s /bin/bash ${USER_NAME} && \
    usermod -aG docker ${USER_NAME}

# Volume directories setup
RUN mkdir -p /home/workspace /var/log && \
    chown -R ${USER_NAME}:${USER_GROUP} /home/workspace /var/log

# Working Directory 설정
WORKDIR /home/workspace

# supervisord 설정 파일 복사
COPY supervisord.conf /etc/supervisord.conf

# 기본 실행 명령어
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]