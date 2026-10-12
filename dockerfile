# kivy/buildozer용 이미지 import
FROM kivy/buildozer:latest

# root에서 작업
RUN pip install --upgrade pip \
&& pip install --no-cache-dir \
    appdirs \
    "colorama>=0.3.3" \
    "sh>=2,<3.0" \
    "wheel~=0.43.0" \
    "setuptools<70.0.0" \
    jinja2 \
    meson \
    ninja \
    build \
    toml \
    packaging \

# root에서 user로
# RUN useradd -m user \
# && chown -R user:user /home/user
USER user
WORKDIR /home/user/account-manager

# 컨테이너 시작
ENTRYPOINT ["/bin/bash"]
CMD ["-i"]