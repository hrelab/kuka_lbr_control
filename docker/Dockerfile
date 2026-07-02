FROM osrf/ros:jazzy-desktop

ARG USER_UID
ARG USER_NAME

ENV DEBIAN_FRONTEND=noninteractive
ENV WORKSPACE=/workspaces/kuka_lbr_control

RUN apt-get update && apt-get install -y \
    sudo \
    python3-pip \
 && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    existing_group="$(getent group "${USER_UID}" | cut -d: -f1 || true)"; \
    if [ -n "${existing_group}" ]; then \
        if [ "${existing_group}" != "${USER_NAME}" ]; then \
            groupmod --new-name "${USER_NAME}" "${existing_group}"; \
        fi; \
    elif ! getent group "${USER_NAME}" >/dev/null 2>&1; then \
        groupadd --gid "${USER_UID}" "${USER_NAME}"; \
    fi; \
    existing_user="$(getent passwd "${USER_UID}" | cut -d: -f1 || true)"; \
    if [ -n "${existing_user}" ]; then \
        if [ "${existing_user}" != "${USER_NAME}" ]; then \
            usermod --login "${USER_NAME}" --home "/home/${USER_NAME}" --move-home "${existing_user}"; \
        fi; \
        usermod --uid "${USER_UID}" --gid "${USER_UID}" --home "/home/${USER_NAME}" --shell /bin/bash "${USER_NAME}"; \
    elif getent passwd "${USER_NAME}" >/dev/null 2>&1; then \
        usermod --uid "${USER_UID}" --gid "${USER_UID}" --home "/home/${USER_NAME}" --shell /bin/bash "${USER_NAME}"; \
    else \
        useradd --no-log-init -r --uid "${USER_UID}" --gid "${USER_UID}" --create-home --home-dir "/home/${USER_NAME}" --shell /bin/bash "${USER_NAME}"; \
    fi; \
    usermod -aG sudo "${USER_NAME}"; \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/"${USER_NAME}"; \
    chmod 0440 /etc/sudoers.d/"${USER_NAME}"; \
    mkdir -p "/home/${USER_NAME}"; \
    chown -R "${USER_UID}:${USER_UID}" "/home/${USER_NAME}"

COPY docker/entrypoint.bash /entrypoint.bash
RUN chmod +x /entrypoint.bash

WORKDIR /home/${USER_NAME}/ros2_ws

ENV HOME=/home/${USER_NAME}
ENV USER=${USER_NAME}

USER ${USER_NAME}

ENTRYPOINT ["/entrypoint.bash"]
CMD ["bash"]
