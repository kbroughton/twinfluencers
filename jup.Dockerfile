FROM python:3.8.1-buster AS builder
RUN apt-get update && apt-get install -y --no-install-recommends --yes python3-venv gcc libpython3-dev && \
    python3 -m venv /venv && \
    /venv/bin/pip install --upgrade pip

FROM builder AS builder-venv

COPY requirements.txt /requirements.txt
RUN /venv/bin/pip install -r /requirements.txt

FROM builder-venv AS tester

COPY . /app
WORKDIR /app
RUN /venv/bin/pytest

FROM jupyter/scipy-notebook:latest AS runner
COPY --from=tester /venv /venv
COPY --from=tester /app /app

WORKDIR /app

#ENTRYPOINT ["/venv/bin/python3", "-m", "twinfluencers"]
ENTRYPOINT ["jupyter", "notebook", "--port=8888", "--ip=0.0.0.0", "--allow-root"]
USER root

LABEL name={NAME}
LABEL version={VERSION}
