FROM osrf/ros:jazzy-desktop

ARG USER_UID
ARG USER_NAME

ENV DEBIAN_FRONTEND=noninteractive
ENV WORKSPACE=/workspaces/kuka_lbr_control

RUN apt-get update && apt-get install -y \
    python3-pip \
 && rm -rf /var/lib/apt/lists/*

RUN if ! getent group "${USER_UID}" >/dev/null 2>&1; then \
            groupadd --gid ${USER_UID} ${USER_NAME}; \
        fi && \
        if ! getent passwd "${USER_UID}" >/dev/null 2>&1; then \
            useradd --no-log-init -r --uid ${USER_UID} --gid ${USER_UID} ${USER_NAME}; \
        fi

COPY docker/entrypoint.bash /entrypoint.bash
RUN chmod +x /entrypoint.bash

WORKDIR /home/${USER_NAME}/ros2_ws

ENV HOME=/home/${USER_NAME}
ENV USER=${USER_NAME}

USER ${USER_NAME}

ENTRYPOINT ["/entrypoint.bash"]
CMD ["bash"]
