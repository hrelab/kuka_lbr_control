ARG ROS_DISTRO=jazzy
FROM ubuntu:24.04

ARG ROS_DISTRO

SHELL ["/bin/bash", "-c"]

ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=1000

ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=${ROS_DISTRO}
ENV WORKSPACE=/workspaces/kuka_lbr_control

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash-completion \
    build-essential \
    cmake \
    curl \
    git \
    locales \
    lsb-release \
    gnupg \
    python3-pip \
    sudo \
    tzdata \
 && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --break-system-packages --no-cache-dir --upgrade \
    colcon-common-extensions \
    rosdep \
    vcstool

RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    -o /usr/share/keyrings/ros-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo ${UBUNTU_CODENAME}) main" \
    > /etc/apt/sources.list.d/ros2.list

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-desktop \
 && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US en_US.UTF-8 && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

RUN set -eux; \
    existing_group="$(getent group "${USER_GID}" | cut -d: -f1 || true)"; \
    group_by_name="$(getent group "${USERNAME}" | cut -d: -f3 || true)"; \
    if [[ -n "${existing_group}" && "${existing_group}" != "${USERNAME}" && -n "${group_by_name}" ]]; then \
      echo "Cannot create group ${USERNAME}:${USER_GID}; name already exists with GID ${group_by_name}" >&2; \
      exit 1; \
    fi; \
    if [[ -n "${existing_group}" ]]; then \
      if [[ "${existing_group}" != "${USERNAME}" ]]; then \
        groupmod --new-name "${USERNAME}" "${existing_group}"; \
      fi; \
    elif [[ -n "${group_by_name}" ]]; then \
      groupmod --gid "${USER_GID}" "${USERNAME}"; \
    else \
      groupadd --gid "${USER_GID}" "${USERNAME}"; \
    fi; \
    existing_user="$(getent passwd "${USER_UID}" | cut -d: -f1 || true)"; \
    uid_by_name="$(id -u "${USERNAME}" 2>/dev/null || true)"; \
    if [[ -n "${existing_user}" && "${existing_user}" != "${USERNAME}" && -n "${uid_by_name}" ]]; then \
      echo "Cannot create user ${USERNAME}:${USER_UID}; name already exists with UID ${uid_by_name}" >&2; \
      exit 1; \
    fi; \
    if [[ -n "${existing_user}" ]]; then \
      if [[ "${existing_user}" != "${USERNAME}" ]]; then \
        old_home="$(getent passwd "${existing_user}" | cut -d: -f6)"; \
        if [[ -d "${old_home}" && "${old_home}" != "/home/${USERNAME}" ]]; then \
          usermod --login "${USERNAME}" --home "/home/${USERNAME}" --move-home "${existing_user}"; \
        else \
          usermod --login "${USERNAME}" --home "/home/${USERNAME}" "${existing_user}"; \
        fi; \
      fi; \
      usermod --uid "${USER_UID}" --gid "${USER_GID}" --shell /bin/bash "${USERNAME}"; \
    elif [[ -n "${uid_by_name}" ]]; then \
      old_home="$(getent passwd "${USERNAME}" | cut -d: -f6)"; \
      if [[ -d "${old_home}" && "${old_home}" != "/home/${USERNAME}" ]]; then \
        usermod --uid "${USER_UID}" --gid "${USER_GID}" --home "/home/${USERNAME}" --move-home --shell /bin/bash "${USERNAME}"; \
      else \
        usermod --uid "${USER_UID}" --gid "${USER_GID}" --home "/home/${USERNAME}" --shell /bin/bash "${USERNAME}"; \
      fi; \
    else \
      useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home --shell /bin/bash "${USERNAME}"; \
    fi; \
    mkdir -p "/home/${USERNAME}"; \
    chown "${USER_UID}:${USER_GID}" "/home/${USERNAME}"; \
    usermod -aG sudo "${USERNAME}"; \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/"${USERNAME}"; \
    chmod 0440 /etc/sudoers.d/"${USERNAME}"

RUN rosdep init 2>/dev/null || true && rosdep update

COPY . /tmp/kuka_lbr_control
RUN apt-get update \
 && rosdep install --from-paths /tmp/kuka_lbr_control --ignore-src -r -y --rosdistro "${ROS_DISTRO}" \
 && rm -rf /var/lib/apt/lists/* /tmp/kuka_lbr_control

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR ${WORKSPACE}
RUN git submodule update --init --recursive

ENV HOME=/home/${USERNAME}
ENV USER=${USERNAME}

USER ${USERNAME}

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
