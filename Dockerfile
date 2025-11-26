FROM python:3.12.12-slim-trixie

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# create app dir early and set working dir
WORKDIR /app

# install minimal build deps (if you need to compile wheels)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# copy only dependency files first so layers cache nicely
COPY pyproject.toml poetry.lock* /app/

# install poetry as root and configure it to install into system site-packages
RUN python -m pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir poetry \
    && poetry config virtualenvs.create false

# install project dependencies (system-wide inside container)
RUN poetry install --no-interaction --no-ansi --no-root

# copy application code

# create app group/user and give ownership of app dir
RUN addgroup --system app \
    && adduser --system --ingroup app app \
    && chown -R app:app /app

# switch to unprivileged user
USER app

COPY . /app

EXPOSE 8000

# DEV: using Django runserver (replace with gunicorn in prod)
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
