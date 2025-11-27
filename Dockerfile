FROM python:3.12.12-slim-trixie

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=app

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
COPY . /app

# create app group/user and give ownership of app dir
RUN groupadd --gid ${GROUP_ID} ${USERNAME} || true \
    && useradd -m -u ${USER_ID} -g ${GROUP_ID} -s /bin/bash ${USERNAME} || true \
    # ensure /app is owned by that user
    && chown -R ${USER_ID}:${GROUP_ID} /app

# switch to unprivileged user
USER  ${USER_ID}:${GROUP_ID}


EXPOSE 8000

# DEV: using Django runserver (replace with gunicorn in prod)
CMD ["./entrypoint.sh"]
