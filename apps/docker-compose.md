`docker compose` is a helpful tool. Some things I learned:

- Having a huge command line with `docker` is awkward. Putting config into different YAML is nice.
- Docker Desktop's resource saver mode is nice, but `docker compose run` won't it start the daemon for some reason. Needed to wake up Docker using a different `docker` command or click the GUI.
- `docker compose up --attach-dependencies` is a nice way to see logs from all containers printed at the same time, but doesn't support CMD args
    - `docker compose run` doesn't seem to have a way to print all logs at the same time
- `git config --global url."https://$GITHUB_TOKEN@github.com/".insteadOf https://github.com/` is handy for hardcoding auth for the whole container
	- ***But*** don't publish docker contains with secrets in them. Newest docker supports [build secrets](https://docs.docker.com/build/building/secrets/#using-build-secrets).
- `docker compose cp service_name:/the/file`  means you can skip the `$(docker ps ...` subshell

## Converting between Compose YAML and Docker CLI
https://www.composerize.com/ and https://www.decomposerize.com/