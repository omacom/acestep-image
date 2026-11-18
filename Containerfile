# acestep.cpp's ace-server, built with Vulkan for AMD GPUs, as
# omarchy-local-ai runs it. Built from ServeurpersoCom/acestep.cpp at a pinned
# commit with the patch in patches/: an API key (--api-key-file, ACE_API_KEY).
# Everything is from Arch Linux's packages at the pinned base.

ARG BASE=docker.io/library/archlinux@sha256:fcee73ea1b96e236248f53a213f71276cc9072d9025b58bce9915e32f19963ae

FROM ${BASE} AS build
RUN pacman -Syu --noconfirm --needed base-devel cmake git vulkan-headers vulkan-icd-loader shaderc spirv-headers
ARG COMMIT=973517be024ff8b6bbd50e0adc9e308ab2ed71b3
RUN git clone https://github.com/ServeurpersoCom/acestep.cpp /src \
 && git -C /src checkout --quiet "$COMMIT" \
 && git -C /src submodule update --quiet --init --recursive
COPY patches/ /patches/
RUN git -C /src apply /patches/*.patch \
 && cmake -S /src -B /build -DGGML_VULKAN=ON -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release \
 && cmake --build /build --target ace-server -j"$(nproc)"
# The licenses of acestep.cpp, ggml and the third-party code built in.
RUN mkdir -p /licenses \
 && cd /src \
 && find . -type f \( -iname 'LICENSE*' -o -iname 'COPYING*' -o -iname 'NOTICE*' \) -print \
    | while read -r file; do install -Dm644 "$file" "/licenses/${file#./}"; done

FROM ${BASE}
# The Vulkan loader and Mesa's RADV driver, which run the GPU; curl for the
# health probe.
RUN pacman -Syu --noconfirm --needed vulkan-icd-loader vulkan-radeon curl \
 && pacman -Scc --noconfirm
COPY --from=build /build/ace-server /usr/bin/ace-server
COPY --from=build /licenses /usr/share/licenses/acestep.cpp
COPY patches/ /usr/share/doc/acestep.cpp/patches/
LABEL org.opencontainers.image.source="https://github.com/omacom/acestep-image"
LABEL org.opencontainers.image.description="acestep.cpp's ace-server, built with Vulkan for omarchy-local-ai"
LABEL org.opencontainers.image.licenses="MIT"
EXPOSE 8085
CMD ["ace-server", "--host", "0.0.0.0", "--port", "8085", "--models", "/models"]
