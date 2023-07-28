# Example Golang Application

This application deploys a basic Golang application.

# Instructions

- **Build the image**

  Just checkout this repository and perform the following commandline:

  ```
  ./gokit-stringservice/scripts/create_image.sh
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
