# ROS2 Humble Docker

Basic Docker container setup for ROS2 Humble.

This auto runs colcon build on start.

## Usage

Put ROS2 packages in `work/src`.

Bring up the container

```
docker compose build
docker compose up -d
docker exec -it <CONTAINER NAME> bash
```
