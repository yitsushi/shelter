require 'thor'
require 'aws-sdk'

module Shelter
  module CLI
    module Stack
      class CloudFormation < Thor
        desc 'status', 'Stack status'
        def status
          target_stack = cf_client.describe_stacks(stack_name: get_attr(:stack_name)).stacks.first

          puts "#{target_stack.stack_name} exists..."
          puts "Created: #{target_stack.creation_time}"

          resources = cf_client.describe_stack_resources(
            stack_name: target_stack.stack_name
          )
          resources.stack_resources.each do |r|
            puts ' __________________________________________________________________________________________'
            puts '| Stack Name | Resource ID              | Resource Type                  | Resource Status |'
            puts "| #{r.stack_name} | #{r.physical_resource_id} | #{r.resource_type} | #{r.resource_status}  |"
            puts ' ------------------------------------------------------------------------------------------'
          end
        rescue Exception => e
          fail Thor::Error, e.message
        end

        desc 'create', 'Create stack'
        def create
          cf_client.create_stack(
            stack_name: get_attr(:stack_name),
            template_body: File.open(get_attr(:template_file)).read,
            capabilities: ['CAPABILITY_IAM'],
            tags: [
              { key: 'client', value: get_attr(:meta)[:client] },
              { key: 'type', value: get_attr(:meta)[:type] },
              { key: 'application', value: get_attr(:meta)[:application] }
            ]
          )
          i = 0
          cf_client.wait_until(:stack_create_complete, stack_name: get_attr(:stack_name)) do |w|
            w.before_attempt do
              i = (i + 1) % SPINNER.size
              print "\r#{SPINNER[i]}"
            end
          end
        rescue Exception => e
          fail Thor::Error, e.message
        end

        desc 'update', 'Update stack'
        def update
          cf_client.update_stack(
            stack_name: get_attr(:stack_name),
            template_body: File.open(get_attr(:template_file)).read,
            capabilities: ['CAPABILITY_IAM']
          )
          i = 0
          cf_client.wait_until(:stack_update_complete, stack_name: get_attr(:stack_name)) do |w|
            w.before_attempt do
              i = (i + 1) % SPINNER.size
              print "\r#{SPINNER[i]}"
            end
          end
        rescue Exception => e
          fail Thor::Error, e.message
        end



        no_commands do
          class << self
            def set_attr(name, value)
              @@_attr ||= {}
              @@_attr[name] = value
            end
          end

          def get_attr(name)
            @@_attr[name] if @@_attr.key? name
          end

          def cf_client
            @cf_client ||= Aws::CloudFormation::Client.new(
              credentials: Aws::Credentials.new(
                ENV.fetch('AWS_ACCESS_KEY_ID'),
                ENV.fetch('AWS_SECRET_ACCESS_KEY')
              )
            )
          end

          def get_public_ip
            target_stack = cf_client.describe_stacks(stack_name: get_attr(:stack_name)).stacks.first

            resources = cf_client.describe_stack_resources(
              stack_name: target_stack.stack_name
            )

            eip = resources.stack_resources.select { |r|
              r.resource_type == 'AWS::EC2::EIP'
            }.first

            eip.physical_resource_id
          end
        end
      end
    end
  end
end


