> **Archived.** This image is now built from [`images/acestep`](https://github.com/omacom/omarchy-local-ai/tree/master/images/acestep) in [omacom/omarchy-local-ai](https://github.com/omacom/omarchy-local-ai) and published as `ghcr.io/omacom/omarchy-local-ai/…`. Images already published from here stay available.

# acestep-image

The container image [omarchy-local-ai](https://github.com/omacom/omarchy-local-ai) runs music models in: [acestep.cpp](https://github.com/ServeurpersoCom/acestep.cpp)'s `ace-server`, built with Vulkan for AMD GPUs, published as `ghcr.io/omacom/acestep`.

It builds `ace-server` from a pinned upstream commit with the patch in [`patches/`](patches):

- [`0001`](patches/0001-server-add-api-key-and-api-key-file.patch): `--api-key`, `--api-key-file` and `ACE_API_KEY`, so every request needs `Authorization: Bearer <key>`.

The runtime layer is Arch Linux, pinned by digest, with the Vulkan loader, Mesa's RADV driver and curl for the health probe. The licenses of acestep.cpp, ggml and the third-party code built into `ace-server` are in `/usr/share/licenses/acestep.cpp`.

## Building and publishing

```sh
podman build -t ghcr.io/omacom/acestep:<commit>-<n> .
podman push ghcr.io/omacom/acestep:<commit>-<n>
```

omarchy-local-ai pins the image by digest in `runtimes/acestep.toml`, with a review of the build in `reviews/`. Drop the patch once upstream has it and the pinned commit includes it.

## License

The build files here are MIT. What the image contains keeps its own licenses, listed above.
