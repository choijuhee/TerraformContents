## IaC 종류

Infrastructure as Code - 코드를 사용한 인프라 Provisioning으로 휴먼에러 예방, 일관성 유지 등의 목적으로 사용
[Image: Image.jpg]

## CloudFormation

AWS native 서비스로, AWS 리소스 생성 관리 및 다양한 서비스와 연동에 편리하다. Web 서비스로 제공되어 작업 이력등을 별도로 관리할 필요가 없어 편리하다

### 사용법

* CloudFormation Template 생성 혹은 Web 으로 제공되는 Designer 를 사용하여 생성하고자 하는 리소스 선언

[Image: Image.jpg]

* StackSet 사용 시 Multi Account 환경의 배포 표준화/자동화 가능

[Image: Image.jpg]

### 사용 문법

```
{
  "AWSTemplateFormatVersion" : "version date",

  "Description" : "JSON string",

  "Metadata" : {
    template metadata
  },

  "Parameters" : {
    set of parameters
  },
  
  "Rules" : {
    set of rules
  },

  "Mappings" : {
    set of mappings
  },

  "Conditions" : {
    set of conditions
  },

  "Transform" : {
    set of transforms
  },

  "Resources" : {
    set of resources
  },
  
  "Outputs" : {
    set of outputs
  }
}
```

* Parameters
    * 스크립트 내부에서 사용 되는 변수값을 선언
    * AWS Managed 변수 선언 시, 화면에서 현 Account 리소스를 자동으로 수집하여 선택형으로 제시
* Rules
* Mappings
    * Key-Val 구조로 스크립트 내부에서 사용되는 Map 형태의 변수값 선언
* Conditions
    * 템플릿 내에서 사용할 수 있는 조건절로, 사용자가 지정한 값 혹은 파라미터의 값을 판단하여 참/거짓으로 값을 도출
    * Condition 의 값으로, 리소스 생성여부를 결정하거나 리소스 내부에 적용될 파라미터를 제한할 수 있다
* Resources
    * AWS 의 모든 리소스를 정의하고 생성할 수 있다
    * 내부에서 생성된 리소스의 값을 참조하여 의존성을 부여할 수 있다
* Outputs
    * Resource 생성 완료 후 사용자에게 출력되는 정보 선언

## SDK - python boto3

code 수준에서, 좀 더 자유롭게 동작 구성이 가능하다. 특히 Lambda 등 Serverless 서비스에서 동작가능한 형태로 다양하게 활용할 수 있다

### 사용법

* Python 용 SDK 로, AWS API 를 호출하는 방식으로 사용 된다.
* [boto3 API Document](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/index.html) 를 참조하면, 사용가능한 API 와 request, response 에대한 상세 설명 확인이 가능하다.

```
`pip install boto3`
```

* 호출 할 서비스 서비스 찾기

[Image: Image.jpg]

* 서비스 내 호출 할 API 찾기
    * API 는 대부분 CLI 와 동일한 규격으로 구성되어 있어, CLI 를 함께 참고해도 좋다

[Image: Image.jpg]

* API 의 Request / Resoponse 확인
    * Request Parameter 에 맞춰서, 호출하는 함수에 동일한 형태로 입력
    * Response 값의 형태를 확인하여, 도출할 데이터 가공 방법을 파악

[Image: Image.jpg][Image: Image.jpg]


###사용 문법

```
import boto3

client = boto3.client({서비스 명 입력})
response = client.{API 로 제공되는 함수 명}()

##example##
# Cloudwatch Logs 의 Log group list 를 호출 
**import** **boto3**
client = boto3.client('logs')
log_group_list = client.describe_log_groups()
```

* boto3.client : connection 을 맺는 객체로 session 을 생성 후, resource type 에 맞게 Client 를 생성한다
* client.{api 명} : 해당  Resource type 에 맞는 Client 에서 호출 가능한 API 를 호출한다
* 이후 API 결과 값을 활용하여, 다른 함수를 호출 할때 사용할 수 있다 

###사용 예제

**[EC2 API 호출]**

```
def stop_ec2(self, target_instance_ids):
        self.client.stop_instances,parameters={'InstanceIds':target_instance_ids})

def terminate_ec2(self, target_instance_ids):
    self.client.terminate_instances,parameters={'InstanceIds':target_instance_ids})

def reboot_ec2(self, target_instance_ids):
    self.client.reboot_instances,parameters={'InstanceIds':target_instance_ids})

def start_ec2(self, target_instance_ids):
    self.client.start_instances,parameters={'InstanceIds':target_instance_ids})

def get_instances(self, instance_ids):
    instances = []
    response = self.client.describe_instances,parameters={'InstanceIds':instance_ids})
    for Reservations in response['Reservations']:
        instances.extend(Reservations['Instances'])
    return instances
    
    
def create_network_acl(self, network_acl_name):
        nacl = self.client.create_network_acl,parameters={'VpcId':self.vpc_id})
        nacl = nacl['NetworkAcl']
        nacl_id = nacl['NetworkAclId']
        resource_list = [nacl_id]
        self.create_tags(resource_list, tag_list=[{'Key':'Name','Value':network_acl_name}])
        return nacl
def delete_network_acl(self, network_acl_id):
        self.client.delete_network_acl,parameters={'NetworkAclId':network_acl_id})

def modify_vpc_endpoint(self, parameters={}):
    self.client.modify_vpc_endpoint,parameters=parameters)

def add_subnet_to_vpc_endpoint(self, vpc_endpoint_id, add_subnet_id_list):
    self.modify_vpc_endpoint(parameters={'VpcEndpointId': vpc_endpoint_id, 'AddSubnetIds':add_subnet_id_list})

def remove_subnet_to_vpc_endpoint(self, vpc_endpoint_id, remove_subnet_id_list):
    self.modify_vpc_endpoint(parameters={'VpcEndpointId': vpc_endpoint_id, 'RemoveSubnetIds':remove_subnet_id_list})
```

**[API 를 사용하여 나만의 로직 구성]**
- EC2 리소스에 대한 상태 변화 작업

```
 def ec2_failure(self, mode, tag_list):
        ec2 = Resources.Ec2Service(self.region_name, self.vpc_id, self.az_name_list, tag_list)
        ec2.assume_role(self.cross_account_role_arn)

        filters = self.common.get_filters_with_tag_list(tag_list, self.az_name_list, self.vpc_id)
        filters.append({'Name': 'instance-state-name', 'Values': ['running']})
        target_instances = ec2.get_filtered_instances(filters)
        target_instance_ids = ec2.get_instance_ids_from_instances(target_instances)
        
        if mode == 'stop':
            try :
                ec2.stop_ec2(target_instance_ids)
            except Exception as e:
                self.logger.info(f'unable to stop instance')
        elif mode == 'terminate':
            try :
                ec2.terminate_ec2(target_instance_ids)
            except Exception as e:
                self.logger.info(f'unable to terminate instance')
        elif mode == 'reboot':
            try :
                ec2.reboot_ec2(target_instance_ids)
            except Exception as e:
                self.logger.info(f'unable to reboot instance')
        else:
            self.logger.info(f'Please enter right mode({mode})')
```

## Terraform

hashcorp 사에서 opensource 로 개발한 IaC. 다양한 서비스들과 연동이 가능하며 특히 Public Cloud 및 k8s와의 연계가 자유롭다. 하나의 서비스에 종속적이지 않고 확장성이 뛰어나 많은 곳에서 활용되고 있다.

### 사용법

* Provider
    * 다양한 Public Cloud, Infrastructure, API 제공 서비스들로 리소스의 Provisioning 대상을 의미한다.
    * Provider 의 API 를 사용하여 Action 을 수행할 수 있다
    * [AWS Provider API Document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

[Image: Image.jpg]
```
provider "aws" {
  alias  = "seoul"
  region = "ap-northeast-2"
}
```




* Registry
    * Provider 를 활용하여, 다양한 Module 을 구성. 사용자가 Provider 가 제공하는 api 를 기반으로 구성하지 않고 간편하게 사용할 수 있다.
    * Submodule : 해당 Module 을 구성하고 있는 하위 Module
    * Examples : 해당 Module 을 활용하여 구성할 수 있는 Template example

[Image: Image.jpg][Image: Image.jpg]

```
module "ecs" {
source = "terraform-aws-modules/ecs/aws"
....
}
```

### 사용 문법

* provider
    * 리소스 배포 시 연동되는 public cloud, infra, api 제공사 등으로 수행되는 API 의 대상
* resource
    * provider 에서 제공하는 Infra resource로 API 기반으로 만들어졌다
    * Provider 의 Document 를 활용하여 어떤 Resource 가 제공되는지 확인할 수 있다
    * [AWS Provider API Document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
    * [AZURE API Document](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
    * [k8s API Document](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)

```
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = data.aws_lb.ecs_service_lb.arn
  port     = var.load_balancer_listener.port
  protocol = var.load_balancer_listener.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = var.cluster

  configuration {
    execute_command_configuration {
      logging    = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.cluster_logs.name
      }
    }
  }
}
```

* variable
    * template 내에서 사용하게 될 변수값으로, 사용자의 입력값에 따라 Template이 다양하게 동작할 수 있다
    * variable 을 잘 활용하면, 코드의 재 사용성을 높여 유연한 template 을 구성할 수 있다
    * type : string, number, bool, list(tuple), map(object) 이 적용 가능하다
        * map 은 구조가 있는 데이터의 경우, 활용하면 활용도가 높다

```
variable "service_name" {}
variable "services" {
  type = map(object({
    launch_type = string
    port = number
    desired_count   = number
  }))
}
variable "subnet_filter" {
  type = list
}
```

* module
    *  Template 을 여러 기능, Resource 의 집합으로 구성하여 재 사용성이 높은 기능으로 활용

```
module "apply_service" {
  source = "./apply_service"

  vpc_id = local.variables.vpc_id
  load_balancer_name = local.variables.load_balancer_name
...
}
```

* output
    * Template 수행 후 출력되는 값으로 사용자가 확인하거나, 이를 상속받아 사용하는 외부 Template 이 값을 활용할 수 있습니다.

```
output "cluster"{
    value =  aws_ecs_cluster.cluster
}

**module "ecs_task_definition" {**
  source = "../modules/task_definition"
  ...
}

module "ecs_service" {
  source = "../modules/service"
  ...
  task_definition = **module.ecs_task_definition.task_definition
  # 상위 module 의 output 으로 task_definition 이 정의되어 있기에, 이를 호출받아 활용 가능
**
```

* data
    * Provider 의 다양한 리소스 혹은 속성 값을 동적으로 가져올 수 있는 기능

```
data "aws_lb" "ecs_service_lb"{
  name = var.load_balancer_name
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = data.aws_lb.ecs_service_lb.arn
  ...
}
```

* locals
    * 해당 Template 내에서 사용할 수 있는 지역변수로 Template 내에서 변경되지 않거나 고유하게 사용할 수 있는 값을 일반적으로 설정

```
locals {
  # environment 별 variable 구분 필요
  env = {
    prod = {
      vpc_id = "{Replace needed}"
      load_balancer_name = "{Replace needed}"
      execution_role_name = "{Replace needed}"
    }
    dev = {
      vpc_id = "{Replace needed}"
      load_balancer_name = "{Replace needed}"
      execution_role_name = "{Replace needed}"
    }
    test = {
      vpc_id = "vpc-123456"
      load_balancer_name = "test-alb"
      execution_role_name = "ecsTaskExecutionRole"
    }
  }

  environment = terraform.workspace
  variables = local.env[local.environment]
}
```
