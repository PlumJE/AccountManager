# Buildozer 기반 이미지
FROM kivy/buildozer:latest

# 가상 화면과 noVNC 구성요소 설치
RUN apt-get update \
&& apt-get install -y \
    xvfb \
    x11vnc \
    novnc \
    fluxbox \
    python3-dev \
    libgl-dev \
    libmtdev1 \
    ca-certificates \
&& rm -rf /var/lib/apt/lists/*

# 컨테이너용 사용자 준비
RUN if ! id -u user; then useradd -m -s /bin/bash user; fi \
&& mkdir -p /home/user/.config \
&& chown -R user:user /home/user \
&& ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# 프로젝트와 사용자 환경 설정
USER user
WORKDIR /home/user

# 프로젝트 파일 복사
COPY . /home/user/

# 호스트 작업 폴더 연결 지점
VOLUME [ "/home/user/hostcwd" ]

# 화면 및 Python 환경 설정
ENV VNC_PORT=5900 \
    NOVNC_PORT=6080 \
    DISPLAY=:0 \
    UV_PROJECT_ENVIRONMENT=/home/user/.venv313
EXPOSE $VNC_PORT $NOVNC_PORT

# uv와 Kivy 설치
RUN pip install uv \
&& uv python pin 3.13 \
&& uv run pip install kivy --break-system-packages

# 컨테이너 시작 시 가상 화면과 noVNC 실행
ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ "set -e; rm -f /tmp/.X0-lock /tmp/.X11-unix/X0; \
    Xvfb ${DISPLAY} -screen 0 1280x720x24 & sleep 1; \
    fluxbox & sleep 1; \
    x11vnc -display ${DISPLAY} -rfbport ${VNC_PORT} -nopw -forever -shared & \
    exec websockify --web=/usr/share/novnc ${NOVNC_PORT} localhost:${VNC_PORT}" ]
