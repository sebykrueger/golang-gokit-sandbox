# Example Golang Application

A template project to create a Docker image for a Go application. The example application exposes an HTTP endpoint.

Features:

- The Docker build uses a
  [multi-stage build setup](https://docs.docker.com/build/building/multi-stage/)
  to minimize the size of the generated Docker image, which is 8MB
- Supports [Docker BuildKit](https://docs.docker.com/build/)
- Golang 1.20.5
- [GitHub Actions workflows](https://github.com/miguno/golang-docker-build-tutorial/actions) for
  [Golang](https://github.com/miguno/golang-docker-build-tutorial/actions/workflows/go.yml)
  and
  [Docker](https://github.com/miguno/golang-docker-build-tutorial/actions/workflows/docker-image.yml)
- Uses [.env](.env) as central configuration to set variables used by
  Docker LABEL Container Image metadata.

# Instructions

- **Build the image**

  Just checkout this repository and perform the following commandline:

  ```
  ./gokit-stringservice/scripts/create_image.sh
  ```

  Optionally, you can check the size of the generated Docker image:

  ```shell
  $ docker images sebykrueger/gokit-stringservice
  REPOSITORY                        TAG       IMAGE ID       CREATED       SIZE
  sebykrueger/gokit-stringservice   latest    01d73b74e08b   2 hours ago   8.19MB
  ```

- **Verfify the Docker labels**

  ```
  docker inspect --format='{{range $k, $v := .Config.Labels}} {{- printf "%s = \"%s\"\n" $k $v -}} {{end}}' docker.io/sebykrueger/gokit-stringservice:latest
  ```

- **Start container**

  ```
  ./gokit-stringservice/scripts/start_container
  ```

- **Verify the Docker labels**

  ```
  docker inspect gokit-stringservice | jq -r '.[0].Config.Labels'
  ```

- At the end, **do not** forget to stop and remove the container:

  ```
  docker kill gokit-stringservice && docker rm gokit-stringservice
  ```

# Notes

You can run the Go application locally if you have Go installed.

```shell
# Build
$ ./scripts/build.sh

# Test
$ go test -cover -v ./...

# Run
$ ./scripts/run.sh
```
