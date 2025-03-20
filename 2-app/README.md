# Containerized Flask Calculator with GitHub Actions

Added flask in requirements.txt
1. Create a Dockerfile

``` 
FROM python:3.9-slim

WORKDIR /app

COPY calculator.py requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8080

CMD ["gunicorn", "-b", "0.0.0.0:8080", "calculator:app"]
```

2. Local testing

- Build the Docker image locally
  
  ```
  docker build -t python-app . 
  ```

- Run the Docker container
  
  ```
  docker run -d -p 8080:8080 --name python-container python-app
  ```
- Test the application in browser:
  ```
  http://localhost:8080/
  ```

3. Automation:

Setup GitHub Secrets
Go to GitHub Repository > Settings > Secrets and Variables > Actions.

Added:
DOCKER_USERNAME → Docker Hub username.
DOCKER_PASSWORD → Docker Hub password.

Automate the following steps using GitHub Actions:
- Trigger the build whenever changes are pushed to the repository on branch main/master
- Build the Docker image using the Dockerfile
- Tag the Docker image with a commit hash
- Push the Docker image to the Docker registry

```
name: Docker Build and Push

on:
  push:
    branches:
      - main
      - master

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build and push
        uses: docker/build-push-action@v2
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: |
            mirunaf/python-app:latest
            mirunaf/python-app:${{ github.sha }}

```
