FROM python:3.10-slim-bullseye

# Disable output stdout, stderr buffering (python -u)
ENV PYTHONUNBUFFERED 1
# Disable .pyc files (python -B)
ENV PYTHONDONTWRITEBYTECODE 1
# Set default encoding to utf-8
ENV PYTHONENCODING=utf-8

COPY ./requirements.txt /tmp/requirements.txt
COPY ./app /app

# Working directory in container
WORKDIR /app

# Port for the app
EXPOSE 8000

RUN apt-get update && \
    apt-get install -y build-essential libpq-dev && \
    pip install virtualenv && \
    virtualenv venv && \
    . /app/venv/bin/activate && \
    pip install --upgrade pip && \
    pip install -r /tmp/requirements.txt && \
    rm -rf /tmp && \
    adduser --disabled-password --no-create-home django-user && \
    chown -R django-user:django-user /app

ENV PATH="/app/venv/bin:$PATH"

# Change to django-user
USER django-user

# initialization for django app
# Static file collection
RUN python3 manage.py collectstatic --no-input
# Create migration files
RUN python3 manage.py makemigrations
# Apply migrations (when Schema changes)
RUN python3 manage.py migrate 
