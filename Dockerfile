# Use the Python 3.9 Alpine Linux base image
FROM python:3.9-alpine3.13

# Set the maintainer label
LABEL maintainer="londonappdeveloper.com"

# Set environment variable to ensure Python runs in buffered mode
ENV PYTHONBUFFERED 1

# Copy requirements files and the app code into the container
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

# Set the working directory to /app
WORKDIR /app

# Expose port 8000
EXPOSE 8000

# Define a build argument for conditional installation of development dependencies
ARG DEV=false

# Create a Python virtual environment and upgrade pip
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip

# Add your PostgreSQL dependencies to install our psycopg package
RUN apk add --update --no-cache postgresql-client

# Install build dependencies temporarily
RUN apk add --update --no-cache --virtual .tmp-build-deps \
    build-base \
    postgresql-dev \
     musl-dev 
    

# Install production requirements
RUN /py/bin/pip install -r /tmp/requirements.txt

# Install development requirements if DEV is set to true
RUN if [ "$DEV" = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt; fi

# Remove temporary files and unused packages
RUN rm -rf /tmp && \
    apk del .tmp-build-deps

# Create a non-root user
RUN adduser \
    --disabled-password \
    --no-create-home \
    django-user

# Add /py/bin to the PATH
ENV PATH="/py/bin:$PATH"

# Set the user to run the container as
USER django-user
