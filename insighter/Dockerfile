FROM python:3.9

COPY . /app
WORKDIR /app

RUN apt-get update -y; apt-get install curl -y
RUN pip install -r requirements.txt

EXPOSE 5010
ENTRYPOINT ["python"]
CMD ["app.py"]
