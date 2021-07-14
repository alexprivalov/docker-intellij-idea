#docker build --compress -t ${DOCKER_IMG_NAME}:${TAG} -f Dockerfile .
#docker build --compress -t docker-intellij-idea:2021.2 -f Dockerfile .
#FROM adoptopenjdk/openjdk8
FROM alexprivalov/openjdk8:debian8
LABEL maintainer "Alex Chupryna <alex.cdev@pinngle.me>"

ARG IDEA_VERSION=2021.2
ARG IDEA_BUILD=212.4638.7

RUN  \
  apt-get update && apt-get install --no-install-recommends -y \
  mc git curl openssh-client less sudo \
  libxtst-dev libxext-dev libxrender-dev libfreetype6-dev \
  libfontconfig1 libgtk2.0-0 libxslt1.1 libxxf86vm1 build-essential \
  ca-certificates sshpass automake vim gcc make cmake bash-completion \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/* \
        && locale-gen en_US.UTF-8 \
        && rm -f /bin/sh && ln -s /bin/bash /bin/sh \
        && chmod +sx /bin/su \
        && chmod +sx /usr/bin/sudo \
        && echo "root:root" | chpasswd  #set default password of root inside docker

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY su-exec /usr/bin/su-exec
RUN chmod +x /usr/local/bin/entrypoint.sh

ARG idea_source=https://download.jetbrains.com/idea/ideaIC-${IDEA_BUILD}.tar.gz
ARG idea_local_dir=.IdeaIC${IDEA_VERSION}

WORKDIR /opt/idea

RUN curl -fsSL $idea_source -o /opt/idea/installer.tgz \
  && tar --strip-components=1 -xzf installer.tgz \
  && rm installer.tgz

#CMD [ "/opt/idea/bin/idea.sh" ]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
