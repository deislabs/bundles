FROM python:2.7

RUN pip install ansible[azure]

COPY app /cnab/app
COPY Dockerfile /cnab/Dockerfile

RUN chmod 755 /cnab/app/run

CMD ["/cnab/app/run"]
