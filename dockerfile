# kivy/buildozer용 이미지 import
FROM kivy/buildozer:latest

# root가 아닌 계정으로 전환해서 안전성 높임
RUN useradd -m user
RUN chown -R user:user /home/user
USER user
RUN /home/user/.venv/bin/python3 -m pip install --no-cache-dir appdirs "colorama>=0.3.3" jinja2 "sh>=2,<3.0" meson ninja build toml packaging setuptools "wheel~=0.43.0"
WORKDIR /home/user/app

# 컨테이너 실행
ENTRYPOINT ["/bin/bash"]
CMD ["-i"]