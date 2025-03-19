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
   
Automate the following steps using GitHub Actions:
Trigger the build whenever changes are pushed to the repository on branch main/master
Build the Docker image using the Dockerfile
Tag the Docker image with a commit hash
Push the Docker image to the Docker registry
