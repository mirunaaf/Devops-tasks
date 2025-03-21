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
name: Deploy Application

on:
  push:
    branches:
      - main
         
jobs:
  build-and-push:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: 2-app
        
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: 2-app
          file: 2-app/Dockerfile
          push: true
          tags: |
            ${{ secrets.DOCKER_USERNAME }}/python-app:latest
            ${{ secrets.DOCKER_USERNAME }}/python-app:${{ github.sha }}

```
4. Ensure the application catches the Docker container's stop signal and performs a clean shutdown

- Adding Signal Handling in calculator.py
  
Modify calculator.py by adding this snippet to handle shutdown signals:

```
def shutdown_signal(signal, _):
    print(f"Received shutdown signal: {signal}")
    sys.exit(0)

signal.signal(signal.SIGTERM, shutdown_signal)  
signal.signal(signal.SIGINT, shutdown_signal)   
```

- Updating Gunicorn Configuration in Dockerfile

Ensure Gunicorn handles shutdown signals correctly by adding:

```
CMD ["gunicorn", "-b", "0.0.0.0:8080", "--timeout", "10", "--graceful-timeout", "10", "calculator:app"]
```
- Testing the graceful shutdown

The container was started with:
```
docker start python-container
```
Then it was stopped using:
```
docker stop python-container
```
Checking logs using:

```
docker logs python-container
```
Results observed:

```
[2025-03-20 23:35:52 +0000] [1] [INFO] Handling signal: term
[2025-03-20 23:35:52 +0000] [7] [INFO] Worker exiting (pid: 7)
Received shutdown signal: 15
```
Gunicorn received SIGTERM from Docker.
Gunicorn allowed the worker to shut down cleanly.
Received shutdown signal: 15 -> this message comes from  the Python signal handler, confirming that the shutdown signal was caught and handled properly.
