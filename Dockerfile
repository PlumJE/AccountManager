# syntax=docker/dockerfile:1

# 이미지 빌드시 수행할 것들
FROM kivy/buildozer:latest

RUN apt-get update \
&& apt-get install -y \
    python3-dev libgl-dev \
    x11vnc xvfb libmtdev1 fluxbox ca-certificates \
&& rm -rf /var/lib/apt/lists/*

RUN if ! id -u user; then useradd -m -s /bin/bash user; fi \
&& mkdir -p /home/user/.config \
&& chown -R user:user /home/user


# user계정에서 수행할 것들
USER user
WORKDIR /home/user

ENV VNC_PORT=5900
ENV DISPLAY=:0
ENV UV_PROJECT_ENVIRONMENT=/home/user/.venv313

RUN pip install uv \
&& uv python pin 3.13 \
&& uv run pip install kivy --break-system-packages

EXPOSE $VNC_PORT
VOLUME [ "/home/user/hostcwd" ]

RUN cat > /home/user/USER_MANUAL.md <<'USER_MANUAL'
# Messages from leejieung/kivy-and-buildozer

## how do I test?
Input `uv run <blabla...>`

## how do I build?
Input `buildozer <blabla...>`

## what should I prohibit myself?
Don't ever write `pyproject.toml` or `uv.lock`!
They will have going the packages away!!
(I tried it.)
USER_MANUAL


# 컨테이너 실행시 수행할 것들
ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ "rm -f /tmp/.X0-lock /tmp/.X11-unix/X0 \
    && Xvfb ${DISPLAY} -screen 0 1280x720x24 & sleep 1 \
    && fluxbox & sleep 1 \
    && x11vnc -display ${DISPLAY} -rfbport ${VNC_PORT} -nopw -forever -shared" \
]
