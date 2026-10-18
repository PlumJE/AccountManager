# syntax=docker/dockerfile:1

# kivy/buildozer용 이미지 import
FROM kivy/buildozer:latest
ARG CONTAINER_NAME



##### root 계정에서의 작업들 #####

# VNC를 위한 패키지 설치
RUN apt-get update \
&& apt-get install -y --no-install-recommends xvfb x11vnc procps \
&& rm -rf /var/lib/apt/lists/*

# uv 전역 설치
RUN pip install --upgrade pip --no-cache-dir uv

# user계정 추가
RUN useradd -m user \
&& mkdir -p /home/user/${CONTAINER_NAME} /home/user/.config /home/user/.vnc \
&& chown -R user:user /home/user



##### user계정에서의 작업들 #####

USER user
WORKDIR /home/user/${CONTAINER_NAME}

# uv 환경을 마운트된 호스트 .venv와 분리
ENV UV_PROJECT_ENVIRONMENT=/home/user/${CONTAINER_NAME}/.venv
ENV VIRTUAL_ENV=/home/user/${CONTAINER_NAME}/.venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

# uv 프로젝트 초기화, kivy 지역 설치
RUN uv python pin 3.13 \
&& uv init \
&& uv add "kivy[base]"

# 컨테이너 시작시 VNC 비밀번호를 매번 입력받고 서버를 시작 (Here-Doc 활용)
RUN cat << 'EOF' > ~/entrypoint.sh
#!/bin/bash

# VNC 비밀번호 자동 생성 (환경변수 VNC_PASSWD가 설정되어 있으면 해당 값 사용, 없으면 '0000')
x11vnc -storepasswd "${VNC_PASSWD:-0000}" "$HOME/.vnc/passwd"

# Xvfb 가상 디스플레이 시작
export DISPLAY=:0
if ! pgrep -x Xvfb >/dev/null; then
    Xvfb :0 -screen 0 1280x800x24 -nolisten tcp >/tmp/xvfb.log 2>&1 &
    sleep 1
fi

# x11vnc 서버 시작
pkill -x x11vnc 2>/dev/null || true
x11vnc -display :0 -rfbauth "$HOME/.vnc/passwd" -forever -shared -rfbport 5900 -listen 0.0.0.0 >/tmp/x11vnc.log 2>&1 &

# 전달된 CMD (예: /bin/bash) 실행
exec "$@"
EOF

# 스크립트 실행 권한 부여
RUN chmod +x /home/user/entrypoint.sh

# 컨테이너 시작 시 entrypoint.sh를 거쳐서 bash로 진입
ENTRYPOINT ["/home/user/entrypoint.sh"]
CMD ["/bin/bash"]
