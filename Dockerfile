# Use the python 3.11 image from the AWS ECR Public Gallery
FROM public.ecr.aws/lambda/python:3.11

# Set the working directory in the container
WORKDIR /var/task

# Copy the requirements.txt file into the container
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the code into the container
COPY . .

# Specify the command to run when the container starts
CMD ["lambda_function.lambda_handler"]
