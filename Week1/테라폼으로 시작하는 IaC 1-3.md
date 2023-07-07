# [Chapter 1-3] 테라폼으로 시작하는 IaC : IaC와 테라폼

## 1. IAC 와 테라폼

#### IaC(Infrastructure as Code) 란?

* 코드를 사용한 인프라 Provisioning으로 휴먼에러 예방, 일관성 유지 등의 목적으로 사용
* ![image](https://github.com/choijuhee/TerraformContents/assets/18410865/39973b83-453f-465e-9bb4-ee474bbb8afd)


#### CloudFormation(AWS)

* AWS native 서비스로, AWS 리소스 생성 관리 및 다양한 서비스와 연동에 편리하다. Web 서비스로 제공되어 작업 이력등을 별도로 관리할 필요가 없어 편리하다
* 사용법
    * CloudFormation Template 생성 혹은 Web 으로 제공되는 Designer 를 사용하여 생성하고자 하는 리소스 선언
        *![image](https://github.com/choijuhee/TerraformContents/assets/18410865/b5123498-f873-4d8f-9355-0e46c7b5ef17)
    * StackSet 사용 시 Multi Account 환경의 배포 표준화/자동화 가능
        * ![image](https://github.com/choijuhee/TerraformContents/assets/18410865/e3a38352-8bb0-4d3f-8dd4-ae908aad7945)

* 사용 문법
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

#### Boto3

* code 수준에서, 좀 더 자유롭게 동작 구성이 가능하다. 특히 Lambda 등 Serverless 서비스에서 동작가능한 형태로 다양하게 활용할 수 있다
* 사용법
    * Python 용 SDK 로, AWS API 를 호출하는 방식으로 사용 된다.
    * [boto3 API Document](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/index.html) 를 참조하면, 사용가능한 API 와 request, response 에대한 상세 설명 확인이 가능하다.

    ```
    pip install boto3
    ```

    * 호출 할 서비스 서비스 찾기
    * ![image](https://github.com/choijuhee/TerraformContents/assets/18410865/d9912dd7-12c1-4361-bcf0-e758465e7d92)


    * 서비스 내 호출 할 API 찾기
        * API 는 대부분 CLI 와 동일한 규격으로 구성되어 있어, CLI 를 함께 참고해도 좋다
        * ![image](https://github.com/choijuhee/TerraformContents/assets/18410865/870c10b8-1427-4a1c-8afb-1efadf4172ec)


    * API 의 Request / Resoponse 확인
        * Request Parameter 에 맞춰서, 호출하는 함수에 동일한 형태로 입력
        * Response 값의 형태를 확인하여, 도출할 데이터 가공 방법을 파악

        * ![image](https://github.com/choijuhee/TerraformContents/assets/18410865/84f83b84-a0a6-4c65-9edf-fc0e034303fc)
        * ![image](https://github.com/choijuhee/TerraformContents/assets/18410865/a6852119-222d-4a51-960a-2a5650464620)



    * 사용 문법

```
import boto3

client = boto3.client({서비스 명 입력})
response = client.{API 로 제공되는 함수 명}()

##example##
# Cloudwatch Logs 의 Log group list 를 호출 
**import** **boto3**
client = boto3.client("logs")
log_group_list = client.describe_log_groups()
```

        * boto3.client : connection 을 맺는 객체로 session 을 생성 후, resource type 에 맞게 Client 를 생성한다
        * client.{api 명} : 해당  Resource type 에 맞는 Client 에서 호출 가능한 API 를 호출한다
        * 이후 API 결과 값을 활용하여, 다른 함수를 호출 할때 사용할 수 있다 
* 사용 예제
    * **[EC2 API 호출]**

```
def stop_ec2(self, target_instance_ids):
        self.client.stop_instances(parameters={"InstanceIds":target_instance_ids})

def terminate_ec2(self, target_instance_ids):
    self.client.terminate_instances(parameters={"InstanceIds":target_instance_ids})

def reboot_ec2(self, target_instance_ids):
    self.client.reboot_instances(parameters={"InstanceIds":target_instance_ids})

def start_ec2(self, target_instance_ids):
    self.client.start_instances(parameters={"InstanceIds":target_instance_ids})

def get_instances(self, instance_ids):
    instances = []
    response = self.client.describe_instances(parameters={"InstanceIds":instance_ids})
    for Reservations in response["Reservations"]:
        instances.extend(Reservations['Instances'])
    return instances
```

* **[API 를 사용하여 나만의 로직 구성]**
    * - EC2 리소스에 대한 상태 변화 작업

```
def ec2_failure(self, mode, tag_list):
        ec2 = Resources.Ec2Service(self.region_name, self.vpc_id, self.az_name_list, tag_list)
        ec2.assume_role(self.cross_account_role_arn)
        ...
        ec2.stop_ec2(target_instance_ids)
```

#### 유형

* On-premise
    * https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
* Hosted SaaS
    * https://app.terraform.io/app/pages/welcome
    * https://developer.hashicorp.com/terraform/tutorials/cloud-get-started
    ![image](https://github.com/choijuhee/TerraformContents/assets/18410865/c7641742-e10c-4063-ad89-14b98d51ba00)
![image](https://github.com/choijuhee/TerraformContents/assets/18410865/004b13fc-d4e3-49b4-9f3f-e8e404ccaace)

* Private Install
    * 네트워크가 격리 된 환경에서 Terraform 을 사용할 수 있는 구성, Enterprise 에서 일반적으로 활용

## 2. 실행 환경 구성

#### 환경 구성

* 테라폼 설치
    * https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
    * `brew install terraform`

## 3. 기본 사용법

#### 대표 Template  Keyword

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

#### Command Line

 <pre><code>
  terraform -help
    - Terraform 사용 방법
    Usage: terraform [global options] <subcommand> [args]
    
    The available commands for execution are listed below.
    The primary workflow commands are given first, followed by
    less common or more advanced commands.
    
    - 주요 Command
    Main commands:
      init          Prepare your working directory for other commands
      validate      Check whether the configuration is valid
      plan          Show changes required by the current configuration
      apply         Create or update infrastructure
      destroy       Destroy previously-created infrastructure
    
    All other commands:
      console       Try Terraform expressions at an interactive command prompt
      fmt           Reformat your configuration in the standard style
      force-unlock  Release a stuck lock on the current workspace
      get           Install or upgrade remote Terraform modules
      graph         Generate a Graphviz graph of the steps in an operation
      import        Associate existing infrastructure with a Terraform resource
      login         Obtain and save credentials for a remote host
      logout        Remove locally-stored credentials for a remote host
      metadata      Metadata related commands
      output        Show output values from your root module
      providers     Show the providers required for this configuration
      refresh       Update the state to match remote systems
      show          Show the current state or a saved plan
      state         Advanced state management
      taint         Mark a resource instance as not fully functional
      test          Experimental support for module integration testing
      untaint       Remove the 'tainted' state from a resource instance
      version       Show the current Terraform version
      workspace     Workspace management
    
    Global options (use these before the subcommand, if any):
      -chdir=DIR    Switch to a different working directory before executing the
                    given subcommand.
      -help         Show this help output, or the help for a specified subcommand.
      -version      An alias for the "version" subcommand.
</pre></code>

* init : Terraform 환경의 초기화. 다양한 소스를 설치하고 Backend 를 구성
* plan : Terraform 코드 기반, 배포/변경 될 Resource 를 사전 확인. Dry-run 개념  
* deploy : Terraform 코드 기반, Resource 의 배포/변경 작업 수행
* destroy : Terraform 으로 구성한 Resource 를 Backend 에 기록된 state 를 기반으로 삭제
* validate : Terraform 코드의 문법을 점검
* fmt : hcl 형태로 입력한 Terraform 코드를 formatting 

#### Backend

* Terraform init 시 저장되는 State 파일을 저장하는 공간으로, default 는 local 이다
* .[terraform.tfstate.lock.info](http://terraform.tfstate.lock.info/) 파일은 State 를 lock 하여, 동시에 apply 하지 않도록 처리한다
* 가장 보편적으로 많이 사용되는 Backend 는 State 저장소로  S3, Lock info 파일 저장소로 Dynamo DB fmf tkdydgksek
* 예제
    * Terraform apply 전
    * ![image](https://github.com/choijuhee/TerraformContents/assets/18410865/20d75e6e-1f31-4b03-94ae-cfad7d8dc7bc)

    * Terraform apply 시 → .terraform[.tfstate.lock.info](http://lock.info/) 파일 생성
    * ![image](https://github.com/choijuhee/TerraformContents/assets/18410865/434ce104-f661-46b7-9c99-812f2ea85cd6)

    * 동시에 같은 Template 에 대한 apply 수행 시도 시 -> state lock 상태로 apply 불가 메세지
    * ![image](https://github.com/choijuhee/TerraformContents/assets/18410865/8ae82992-03f0-4a25-89aa-b7ecced3551d)

* Backend 구성 - S3 / DDB
    * terraform{
          backend "s3" {
            bucket         = "terraform-backend-abcd"
            key            = "terraform.tfstate"
            region         = "ap-northeast-2"
            dynamodb_table = "terraform-backend"
          }
        }
  * ![image](https://github.com/choijuhee/TerraformContents/assets/18410865/9e48844f-67de-4940-8914-d0b09dfaa5f8)
  * ![image](https://github.com/choijuhee/TerraformContents/assets/18410865/5c4ecec1-8c34-4bc9-a997-f91fb156da6f)

* Resource 종속성
    * 선언된 Resource, Module 객체를 다른 Resource 객체에서 참조하게 되면 서로 종속 구조가 생성된다
    * 예제 ) 같은 객체를 생성하나, 첫번째 그림은 local_file.abc 가 local_file.def 를 참조하여 생성하였다
        * [Image: Image.jpg]
        * resource "local_file" "abc" {
              content  = "123!"
              filename = "${path.module}/abc.txt"
            }
            
            resource "local_file" "def" {
              depends_on = [
                **local_file****.abc**
              ]
            
              content  = "456!"
              filename = "${path.module}/def.txt"
            }
* Lifecycle
    * 리소스의 lifecycle 에 조건을 부여하여 사전/사후에 부여하는 선언자
    * create_before_destory : 리소스 재 배포 시, 기존 리소스 삭제 전 생성
    * prevent_destroy : 리소스의 destroy 를 거부
    * ignore_changes : resource 내 특정 속성값을 변경하지 않도록 선언
    * precondition : 리소스 생성 전, 사전 조건을 점검
    * postcondition : 리소스 생성 후, 조건을 점검. Resource 간 종속성이 있을때 이후 생성 될 리소스를 생성하기 전 점검하는 방법
