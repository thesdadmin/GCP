FROM gcr.io/google.com/cloudsdktool/google-cloud-cli:latest

COPY build/cert_rotation_cm.sh /home/cloudsdk/

RUN chmod +x /home/cloudsdk/cert_rotation_cm.sh

USER 1000:1000

ENTRYPOINT ["/bin/bash"]

CMD ["./home/cloudsdk/cert_rotation_cm.sh"]


