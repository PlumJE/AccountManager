# kivy/buildozer용 이미지 import
FROM kivy/buildozer:latest

# root가 아닌 계정으로 전환해서 안전성 높임
RUN useradd -m user
RUN chown -R user:user /home/user
USER user
WORKDIR /home/user/app

# 컨테이너 실행
ENTRYPOINT ["/bin/bash"]
CMD ["-i"]