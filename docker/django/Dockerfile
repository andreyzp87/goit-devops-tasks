FROM python:3.11-slim

WORKDIR /app

COPY testproject/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

ENV POSTGRES_HOST=${POSTGRES_HOST}
ENV POSTGRES_PORT=${POSTGRES_PORT}
ENV POSTGRES_DB=${POSTGRES_DB}
ENV POSTGRES_USER=${POSTGRES_USER}
ENV POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
ENV ALLOWED_HOSTS=${ALLOWED_HOSTS}
ENV DEBUG=${DEBUG}

COPY ./testproject .

EXPOSE 8000

CMD ["python", "/app/manage.py", "runserver", "0.0.0.0:8000"]
