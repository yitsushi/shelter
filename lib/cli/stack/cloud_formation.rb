# frozen_string_literal: true

require 'thor'
require 'aws-sdk'

module Shelter
  module CLI
    module Stack
      # CloudFormation based stack base
      class CloudFormation < Thor
        desc 'status', 'Stack status'
        def status
          stack = cf_client.describe_stacks(
            stack_name: get_attr(:stack_name)
          ).stacks.first

          puts "#{stack.stack_name} exists | #{stack.creation_time}"

          cf_client.describe_stack_resources(
            stack_name: stack.stack_name
          ).stack_resources.each { |r| display_stack_resource(r) }
        end

        desc 'create', 'Create stack'
        def create
          cf_client.create_stack(
            stack_name: get_attr(:stack_name),
            template_body: File.open(get_attr(:template_file)).read,
            capabilities: ['CAPABILITY_IAM'],
            tags: stack_meta
          )
          cf_client.wait_until(
            :stack_create_complete,
            stack_name: get_attr(:stack_name)
          )
        end

        desc 'update', 'Update stack'
        def update
          cf_client.update_stack(
            stack_name: get_attr(:stack_name),
            template_body: File.open(get_attr(:template_file)).read,
            capabilities: ['CAPABILITY_IAM']
          )
          cf_client.wait_until(
            :stack_update_complete,
            stack_name: get_attr(:stack_name)
          )
        end

        # Attribute helpers
        no_commands do
          class << self
            attr_accessor :_attr
            def set_attr(name, value)
              self._attr ||= {}
              self._attr[name] = value
            end
          end

          def get_attr(name)
            self.class._attr[name] if self.class._attr.key? name
          end
        end

        # AWS helpers
        no_commands do
          def cf_client
            @cf_client ||= Aws::CloudFormation::Client.new(
              credentials: Aws::Credentials.new(
                ENV.fetch('AWS_ACCESS_KEY_ID'),
                ENV.fetch('AWS_SECRET_ACCESS_KEY')
              )
            )
          end

          def display_stack_resource(r)
            puts "Stack Name: #{r.stack_name}"
            puts "Resource ID: #{r.physical_resource_id}"
            puts "Resource Type: #{r.resource_type}"
            puts "Resource Status: #{r.resource_status}"
          end

          def stack_meta
            [
              { key: 'client', value: get_attr(:meta)[:client] },
              { key: 'type', value: get_attr(:meta)[:type] },
              { key: 'application', value: get_attr(:meta)[:application] }
            ]
          end
        end
      end
    end
  end
end
