FROM docker.litellm.ai/berriai/litellm:v1.80.15.rc.1

# Install boto3 for AWS Bedrock support
RUN pip install boto3>=1.28.57

# Verify installation
RUN python -c "import boto3; print(boto3.__version__)"