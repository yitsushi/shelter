# Basic Directory Structure

By default, Shelter is looking for a directory named `resources` with a
subdirectory name `templates`.

In the templates subdirectory, we can define different templates. They
have to be a valid CloudFormation `.yaml` file.

In the resources directory, we can define different resources. They have
to be defined in `.yaml` format with a few specific tags in it.

```
+-- resources
|   +-- templates
|   |   `-- restricted-s3.yaml
|   `-- testbucketresource.yaml
```

You can specify where is your resources directory in `Shelterfile.rb`
with `resource_directory`.

## Templates definition

In our example above, we have only one template named `restricted-s3`.
This template defined a CloudFormation stack that contains an S3 bucket,
an IAM User and a Policy for that specific user which restricts the user
to be able to reach only our new S3 Bucket, but nothing else. For the
IAM User, we create a new AccessKey pair, so we can use the
credentials in our infrastructure. Now, for the simplicity, we did not
define a KMS key.

As an output we export the newly created `AccessKeyID` and
`AccessKeySecret` pair.

We have three template parameters:

 - S3 Bucket name
 - Client name for tagging our S3 Bucket (reason: billing)
 - Project name for tagging our S3 Bucket (reason: billing)

**resources/templates/restricted-s3.yaml**

```yaml
---
AWSTemplateFormatVersion: "2010-09-09"
Parameters:
  BucketName:
    Type: String
    Description: Created S3 bucket
  Client:
    Type: String
    Description: Name of the client for tagging
  Project:
    Type: String
    Description: Project tag
Resources:
  Bucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Ref BucketName
      Tags:
        - { Key: "project", Value: !Ref Project }
        - { Key: "client", Value: !Ref Client }
  S3Policy:
    Type: "AWS::IAM::Policy"
    Properties:
      PolicyName: !Join ["-", ["s3", !Ref BucketName]]
      Users:
        - !Ref NewUser
      PolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Effect: "Allow"
            Action:
              - "s3:PutObject"
              - "s3:GetObjectAcl"
              - "s3:GetObject"
              - "s3:GetObjectTorrent"
              - "s3:GetBucketTagging"
              - "s3:GetObjectTagging"
              - "s3:ListBucket"
              - "s3:PutObjectTagging"
              - "s3:DeleteObject"
            Resource:
              - !GetAtt [Bucket, Arn]
              - !Join ["", [!GetAtt [Bucket, Arn], "/*"]]
  NewUser:
    Type: "AWS::IAM::User"
    Properties:
      UserName: !Join ["-", ["s3", !Ref BucketName, "user"]]
      Path: /
  AccessKey:
    Type: AWS::IAM::AccessKey
    Properties:
      UserName: !Ref NewUser

Outputs:
  AccessKeyID:
    Value:
      !Ref AccessKey
  SecretKeyID:
    Value: !GetAtt AccessKey.SecretAccessKey
```

## Resource definition

Now we have a template named `restricted-s3`. We can start creating
resources with this template. For now, we can create a backup user and S3
bucket, so all of our servers with a specific label can call AWS API to
make some backup on our specific S3 bucket.

Let's create a file under resources:

**resources/testbucketresource.yaml:**

```yaml
---
name: testbucketresource
template: restricted-s3
capabilities:
  - CAPABILITY_NAMED_IAM
tags:
  random: yes
  project: test
  client: cheppers
  extra: something
parameters:
  BucketName: my-testresource
  Client: cheppers
  Project: test
```

Here we go. Basically, all of the keys in this file are required, or if
we don't define them, they will be empty (like tags).

**Name:** This will be the name of our resource. It will be stack
name as well but prefixed with the `res-` string. In this case
`res-testbucketresource`.

**Template**: This value defines which one of our template we want to
use. In this case, we want to use our only one `restricted-s3` which is
defined in `resources/templates/restricted-s3.yaml`.

**Capabilities**: AWS CloudFormation capabilities. For more details check the
[AWS API Documentation](docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_CreateStack.html).
Now we want to manage IAM resources, so we need `CAPABILITY_IAM`
in general, but now we give them custom names so we need
`CAPABILITY_NAMED_IAM`.

**Tags**: This is a simple key-value list. Our CloudFormation stack will
be tagged with these tags.

**Parameters**: This is a simple key-value list. That's how we can
define parameters for our CloudFormation template.

# CLI

```
Commands:
  shelter resource create <resource-name>  # Create a specific resource
  shelter resource delete <resource-name>  # Delete a specific resource
  shelter resource help [COMMAND]          # Describe subcommands or one specific subcommand
  shelter resource list                    # List all managed resources
  shelter resource output <resource-name>  # Display resource output
  shelter resource status <resource-name>  # Resource status
  shelter resource update <resource-name>  # Update a specific resource
```

### list

With `list` we can check our resource inventory.

```
$ bundle exec shelter resource list
testbucketresource
```

### create

With `create`, we can create a specific resource.

```
$ bundle exec shelter resource create testbucketresource
Waiting for 'stack_create_complete' on 'res-testbucketresource'...
```

### update

With `update`, we can update a specific resource.

```
$ bundle exec shelter resource update testbucketresource
Waiting for 'stack_update_complete' on 'res-testbucketresource'...
```

### status

With `status`, we can ask for the stack status.

```
$ bundle exec shelter resource status testbucketresource
Resource ID: AKIXXXXXXXXXXXXXXXXX
  Resource Type: AWS::IAM::AccessKey
  Resource Status: CREATE_COMPLETE
Resource ID: cheppers-testresource
  Resource Type: AWS::S3::Bucket
  Resource Status: CREATE_COMPLETE
Resource ID: s3-cheppers-testresource-user
  Resource Type: AWS::IAM::User
  Resource Status: CREATE_COMPLETE
Resource ID: res-t-S3Po-W66XXXXXXXXX
  Resource Type: AWS::IAM::Policy
  Resource Status: CREATE_COMPLETE
```

### output

If we defined Outputs in our template, we can easily list them all with
the `output` command.

```
$ bundle exec shelter resource output testbucketresource
AccessKeyID: AKIXXXXXXXXXXXXXXXXX
SecretKeyID: 3cXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXuI
```

### delete

With `delete` we can delete the whole stack.

```
$ bundle exec shelter resource delete testbucketresource
Waiting for 'stack_delete_complete' on 'res-testbucketresource'...
```