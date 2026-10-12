# Python, Buildozer 등이 포함된 kivy/buildozer 베이스 이미지 사용
FROM kivy/buildozer:latest
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# 시스템 필수 패키지 및 Kivy/C 익스텐션 컴파일에 필요한 라이브러리(libmtdev1, X11 관련 라이브러리 포함) 설치
RUN apt-get update \
&&  apt-get install -y \
    python3-dev \
    python3.13 \
    python3.13-dev \
    python3.13-venv \
    libjpeg-dev \
    zlib1g-dev \
    libpng-dev \
    libmtdev1 \
    libgl1-mesa-glx \
    libxi6 \
    libxcursor1 \
    libxinerama1 \
    libxrandr2 \
    git \
&&  rm -rf /var/lib/apt/lists/*

# 권한 꼬임 방지를 위한 일반 사용자 계정 설정
RUN id -u user >/dev/null 2>&1 || useradd -m user \
&&  chown -R user:user /home/user \
&&  chmod -R 755 /home/user

USER user
WORKDIR /home/user/account-manager

# uv를 사용하여 Python 3.13을 기본으로 하는 가상환경(~/.venv) 생성 및 kivy 설치
RUN uv python pin 3.13 \
&&  uv venv /home/user/.venv --python 3.13 \
&&  . /home/user/.venv/bin/activate \
&&  uv pip install "kivy[base]"

# 컨테이너 시작 시 가상환경 자동 활성화 및 X11 DISPLAY 환경변수 기본값 설정
RUN echo "source /home/user/.venv/bin/activate" >> /home/user/.bashrc \
&&  echo "export DISPLAY=\${DISPLAY:-:0}" >> /home/user/.bashrc

# 컨테이너 시작
ENTRYPOINT ["/bin/bash"]
CMD ["-i"]