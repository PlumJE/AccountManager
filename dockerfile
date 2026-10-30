# 1. KasmVNC 공식 이미지에서 파일 추출용
FROM kasmweb/core-ubuntu-jammy:1.18.0 AS kasm

# 2. Python 3.13, uv, Kivy 준비
FROM python:3.13 AS python313
RUN pip install --no-cache-dir uv kivy

# 3. Buildozer 환경에 KasmVNC를 결합
FROM kivy/buildozer:latest

# 4. buildozer 환경에 결합
RUN apt-get update \
&& apt-get install -y --no-install-recommends \
    fluxbox \
    libgl-dev \
    libmtdev1 \
    libunwind8 \
    libxfont2 \
    x11-xkb-utils \
    xkb-data \
    ca-certificates \
&& mkdir -p /tmp/.X11-unix \
&& chmod 1777 /tmp/.X11-unix \
&& rm -rf /var/lib/apt/lists/*

# 4. KasmVNC와 Python 3.13 실행 환경을 복사
COPY --from=kasm /usr/share/kasmvnc /usr/share/kasmvnc
COPY --from=kasm /usr/bin/Xkasmvnc /usr/bin/Xkasmvnc
COPY --from=python313 /usr/local /usr/local

# 5. 사용자 계정 및 KasmVNC 설정 구성
RUN if ! id -u user >/dev/null 2>&1; then useradd -m -s /bin/bash user; fi \
&& mkdir -p /home/user/.config /home/user/.vnc \
&& printf 'desktop:\n  resolution:\n    width: 1280\n    height: 720\n  allow_resize: false\n' > /home/user/.vnc/kasmvnc.yaml \
&& chown -R user:user /home/user

# 6. 일반 사용자 권한으로 전환
USER user
WORKDIR /home/user

VOLUME [ "/home/user/hostcwd" ]

ENV KASMVNC_PORT=6080 \
    DISPLAY=:0 \
    SCREEN_WIDTH=1280 \
    SCREEN_HEIGHT=720 \
    UV_PROJECT_ENVIRONMENT=/home/user/.venv313 \
    UV_PYTHON=/usr/local/bin/python3.13

EXPOSE $KASMVNC_PORT

# 7. 실행 엔트리포인트 설정
ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ "set -e; \
    Xkasmvnc ${DISPLAY} -geometry ${SCREEN_WIDTH}x${SCREEN_HEIGHT} -depth 24 \
        -interface 0.0.0.0 -websocketPort ${KASMVNC_PORT} \
        -sslOnly 0 -disableBasicAuth -SecurityTypes None \
        -AcceptSetDesktopSize 0 -httpd /usr/share/kasmvnc/www & \
    vnc_pid=$!; sleep 1; \
    fluxbox & \
    wait ${vnc_pid}" ]
