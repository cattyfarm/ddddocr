#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

IMAGE="${IMAGE:-ddddocr-server}"
mkdir -p dist

docker build -f Dockerfile.server -t "$IMAGE" .

cid=$(docker create "$IMAGE")
docker cp "$cid:/usr/local/bin/ddddocr" dist/ddddocr-linux-x86_64
docker rm "$cid" >/dev/null

xwin() {
	docker run --rm --user "$(id -u):$(id -g)" -v "$PWD:/io" -w /io \
		-e HOME=/io/target/xwin-home \
		-e CARGO_HOME=/io/target/xwin-home/cargo \
		-e XWIN_CACHE_DIR=/io/target/xwin-home/xwin \
		ghcr.io/rust-cross/cargo-xwin:0.23.1 \
		cargo xwin "$@"
}

xwin cache xwin
ln -sf pathcch.lib target/xwin-home/xwin/xwin/sdk/lib/um/x86_64/PathCch.lib
xwin build --release --target x86_64-pc-windows-msvc
cp target/x86_64-pc-windows-msvc/release/ddddocr.exe dist/ddddocr-windows-x86_64.exe

ls -la dist
