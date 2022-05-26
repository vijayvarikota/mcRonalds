FROM python:3.9-slim

COPY . /app
WORKDIR /app

ENV APP_PORT=5011

RUN apt-get update -y; apt-get install curl -y
RUN pip install -r requirements.txt

EXPOSE ${APP_PORT}

HEALTHCHECK CMD curl --fail http://localhost:${APP_PORT}/ || exit 1

ENTRYPOINT ["python"]
CMD ["app.py"]
