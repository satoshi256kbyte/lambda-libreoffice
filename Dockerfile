FROM public.ecr.aws/lambda/provided:al2

# Copy custom runtime bootstrap
COPY bootstrap ${LAMBDA_RUNTIME_DIR}
RUN chmod 0755 ${LAMBDA_RUNTIME_DIR}/bootstrap

# Copy function code
COPY function.sh ${LAMBDA_TASK_ROOT}
RUN chmod 0755 ${LAMBDA_TASK_ROOT}/function.sh

# Install
RUN yum install -y awscli
RUN yum install -y jq
# Install Libreoffice
RUN yum install -y amazon-linux-extras
# https://aws.amazon.com/jp/premiumsupport/knowledge-center/ec2-install-extras-library-software/
RUN amazon-linux-extras enable libreoffice
RUN yum clean metadata
RUN yum install -y libreoffice libreoffice-langpack-ja
RUN yum install -y ipa-gothic-fonts ipa-pgothic-fonts

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "function.handler" ]

