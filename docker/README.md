# Docker

This folder contains a ROS 2 Jazzy container setup for the workspace.

## Build and start

```bash
cd docker
USER_UID=$(id -u) USER_GID=$(id -g) docker compose up --build
```

The compose file mounts the repository into `/workspaces/kuka_lbr_control`, sources ROS on startup, and keeps the container interactive. The build args create the container user with the same name, UID, and GID as your host user so files written in the bind mount stay owned by you.

For repeated use, the helper script exports the host identity before calling Docker Compose:

```bash
cd docker
./compose-host-user.sh up --build
```

## Inside the container

```bash
colcon build --symlink-install
source install/setup.bash
ros2 launch kuka_control <launch_file>.py
```

## Notes

- The container uses `network_mode: host` so FRI traffic can reach the robot without extra port mapping.
- GUI tools such as RViz and Gazebo can use the host X11 socket mounted by compose.
- If your desktop refuses X11 connections, allow local clients on the host before starting the container.
