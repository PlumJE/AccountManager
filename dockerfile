# kivy/buildozer용 이미지 import
FROM kivy/buildozer:latest

# root계정에서 작업
RUN pip install --upgrade pip --no-cache-dir uv
RUN useradd -m user \
&& mkdir -p /home/user/account-manager \
&& chown -R user:user /home/user

# root계정에서 user계정으로
USER user
WORKDIR /home/user/account-manager

# user계정에서 작업
RUN uv python pin 3.13 \
&& uv init \
&& uv add "kivy[base]"

# 컨테이너 시작
ENTRYPOINT ["/bin/bash"]
CMD ["-i"]