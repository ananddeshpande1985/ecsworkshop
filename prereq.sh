sudo yum install -y jq
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws cloud9 update-environment  --environment-id $C9_PID --managed-credentials-action DISABLE
rm -vf ${HOME}/.aws/credentials
echo "export AWS_DEFAULT_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)" >> ~/.bashrc
echo "export AWS_REGION=\$AWS_DEFAULT_REGION" >> ~/.bashrc
echo "export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)" >> ~/.bashrc
source ~/.bashrc
test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || echo AWS_REGION is not set
echo "export AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID}" | tee -a ~/.bash_profile
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bash_profile
aws configure set default.region ${AWS_REGION}
aws configure get default.region
aws sts get-caller-identity --query Arn | grep ecsworkshop-admin -q && echo "IAM role valid" || echo "IAM role NOT valid"
pip3 install --user --upgrade boto3
export instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
python3 -c "import boto3
import os
from botocore.exceptions import ClientError 
ec2 = boto3.client('ec2')
volume_info = ec2.describe_volumes(
    Filters=[
        {
            'Name': 'attachment.instance-id',
            'Values': [
                os.getenv('instance_id')
            ]
        }
    ]
)
volume_id = volume_info['Volumes'][0]['VolumeId']
try:
    resize = ec2.modify_volume(    
            VolumeId=volume_id,    
            Size=30s
    )
    print(resize)
except ClientError as e:
    if e.response['Error']['Code'] == 'InvalidParameterValue':
        print('ERROR MESSAGE: {}'.format(e))"
if [ $? -eq 0 ]; then
    sudo reboot
fi

# Install prerequisite packages
sudo yum -y install jq nodejs python36 siege

# Install ecs cli for local testing
sudo curl -so /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest
sudo chmod +x /usr/local/bin/ecs-cli

# Setting CDK Version
export AWS_CDK_VERSION="1.122.0"

# Install aws-cdk
npm install -g --force aws-cdk@$AWS_CDK_VERSION

# Install cdk packages
pip3 install --user --upgrade aws-cdk.core==$AWS_CDK_VERSION \
aws-cdk.aws_ecs_patterns==$AWS_CDK_VERSION \
aws-cdk.aws_ec2==$AWS_CDK_VERSION \
aws-cdk.aws_ecs==$AWS_CDK_VERSION \
aws-cdk.aws_servicediscovery==$AWS_CDK_VERSION \
aws_cdk.aws_iam==$AWS_CDK_VERSION \
aws_cdk.aws_efs==$AWS_CDK_VERSION \
aws_cdk.aws_appmesh==$AWS_CDK_VERSION \
awscli \
awslogs

# Setting environment variables required to communicate with AWS API's via the cli tools
echo "export AWS_DEFAULT_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)" >> ~/.bashrc
echo "export AWS_REGION=\$AWS_DEFAULT_REGION" >> ~/.bashrc
echo "export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)" >> ~/.bashrc
source ~/.bashrc

cd ~/environment
git clone https://github.com/aws-containers/ecsdemo-platform
git clone https://github.com/aws-containers/ecsdemo-frontend
git clone https://github.com/aws-containers/ecsdemo-nodejs
