## Container Base Image Sizes
Different possible [[libc]] in containers.

*Size can be recomputed by running [[regen-docker-size.ps1]]*

| Base Image                                 | libc  | Size   | Use Case                                                  |
| :----------------------------------------- | :---- | :----- | :-------------------------------------------------------- |
| `FROM scratch`                             | None  | 0 MB   | Statically linked (Go, Rust, C/C++ with `-static`)        |
| `FROM gcr.io/distroless/static-debian13`   | None  | 2 MB   | Static binaries only; no shell                            |
| `FROM cgr.dev/chainguard/static`           | None  | 2 MB   | Distroless-style                                          |
| `FROM alpine`                              | musl  | 8 MB   | Minimal dynamic linking with musl                         |
| `FROM cgr.dev/chainguard/glibc-dynamic`    | glibc | 9 MB   | Minimal Chainguard hardened                               |
| `FROM cgr.dev/chainguard/wolfi-base`       | glibc | 13 MB  | Wolfi OS; shell + apk; Chainguard's Alpine analogue       |
| `FROM gcr.io/distroless/base-debian13`     | glibc | 33 MB  | CGO Go / C with libssl; no shell                          |
| `FROM gcr.io/distroless/cc-debian13`       | glibc | 36 MB  | Adds libgcc + libstdc++; for C++/Rust needing GCC runtime |
| `FROM gcr.io/distroless/python3-debian13`  | glibc | 69 MB  | Python runtime                                            |
| `FROM debian:stable-slim`                  | glibc | 95 MB  | Slim Debian with apt                                      |
| `FROM debian:stable`                       | glibc | 135 MB | Full Debian with apt                                      |
| `FROM gcr.io/distroless/nodejs24-debian13` | glibc | 150 MB | Node.js runtime                                           |
| `FROM gcr.io/distroless/java25-debian13`   | glibc | 223 MB | Java runtime                                              |

