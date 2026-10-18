#
# kivy/buildozer용 이미지 import
#
FROM kivy/buildozer:latest
ARG CONTAINER_NAME



#
# root 계정에서의 작업들
#

# VNC를 위한 패키지 설치
RUN apt-get update \
&& apt-get install -y --no-install-recommends xvfb x11vnc procps \
&& rm -rf /var/lib/apt/lists/*

# uv 설치
RUN pip install --upgrade pip --no-cache-dir uv

# user계정 추가
RUN useradd -m user \
&& mkdir -p /home/user/${CONTAINER_NAME} /home/user/.config \
&& chown -R user:user /home/user



#
# user계정에서의 작업들
#
USER user
WORKDIR /home/user/${CONTAINER_NAME}

# uv 환경을 마운트된 호스트 .venv와 분리
ENV UV_PROJECT_ENVIRONMENT=/home/user/${CONTAINER_NAME}/.venv
ENV VIRTUAL_ENV=/home/user/${CONTAINER_NAME}/.venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

# uv 프로젝트 초기화 & kivy 설치
RUN uv python pin 3.13 \
&& uv init \
&& uv add "kivy[base]"

# Interactive Bash에서 VNC 비밀번호를 매번 입력받고 서버를 시작
RUN printf '%s\n' \
    'if [[ $- == *i* ]]; then' \
    '  mkdir -p "$HOME/.vnc"' \
    '  x11vnc -storepasswd' \
    '  export DISPLAY=:0' \
    '  if ! pgrep -x Xvfb >/dev/null; then' \
    '    Xvfb :0 -screen 0 1280x800x24 -nolisten tcp >/tmp/xvfb.log 2>&1 &' \
    '    sleep 1' \
    '  fi' \
    '  pkill -x x11vnc 2>/dev/null || true' \
    '  x11vnc -display :0 -rfbauth "$HOME/.vnc/passwd" -forever -shared -rfbport "$VNC_PORT" -listen 0.0.0.0 >/tmp/x11vnc.log 2>&1 &' \
    'fi' >> /home/user/.bashrc

# bash로 컨테이너 접속
ENTRYPOINT ["/bin/bash"]
CMD ["-i"]
