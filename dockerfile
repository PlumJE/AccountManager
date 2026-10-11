# Python, Buildozer 등이 포함된 kivy/buildozer 베이스 이미지 사용
# uv 패키지 관리자 추가 (필요한 경우)
FROM kivy/buildozer:latest
COPY --from=ghcr.io/astral-sh/uv:0.13.0 /uv /uvx /bin/

# C 익스텐션 컴파일 및 깃 관리에 꼭 필요한 시스템 필수 헤더/라이브러리만 설치
RUN apt-get update \
&&  apt-get install -y \
    python3-dev \
    libjpeg-dev \
    zlib1g-dev \
    libpng-dev \
    git \
&&  rm -rf /var/lib/apt/lists/*

# 권한 꼬임 방지를 위한 일반 사용자 계정 설정
RUN ! id -u user && useradd -m user \
&&  chown -R user:user /home/user \
&&  chmod -R 755 /home/user

USER user
WORKDIR /home/user/account-manager

# 컨테이너 시작
ENTRYPOINT ["/bin/bash"]
CMD ["-i"]
