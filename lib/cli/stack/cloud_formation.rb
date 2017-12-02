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

          cf_client.describe_stack_resources(
            stack_name: stack.stack_name
          ).stack_resources.each { |r| display_stack_resource(r) }
        rescue Aws::CloudFormation::Errors::ValidationError
          puts "#{get_attr(:stack_name)} does not exist"
        end

        desc 'output', 'Display resource output'
        def output
          stack = cf_client.describe_stacks(
            stack_name: get_attr(:stack_name)
          ).stacks.first

          stack.outputs.each { |out| display_stack_output(out) }
        end

        desc 'create', 'Create stack'
        def create
          cf_client.create_stack(
            stack_name: get_attr(:stack_name),
            capabilities: get_attr(:capabilities),
            template_body: File.open(get_attr(:template_file)).read,
            tags: meta, parameters: stack_params(get_attr(:parameters))
          )
          wait_until(:stack_create_complete, get_attr(:stack_name))
        end

        desc 'update', 'Update stack'
        def update
          cf_client.update_stack(
            stack_name: get_attr(:stack_name),
            capabilities: get_attr(:capabilities),
            template_body: File.open(get_attr(:template_file)).read,
            tags: meta, parameters: stack_params(get_attr(:parameters))
          )
          wait_until(:stack_update_complete, get_attr(:stack_name))
        rescue Aws::CloudFormation::Errors::ValidationError => e
          puts e.message
        end

        desc 'delete', 'Delete the stack'
        def delete
          raise 'Stack is not deletable!!!' unless get_attr(:deletable)
          cf_client.delete_stack(stack_name: get_attr(:stack_name))
          wait_until(:stack_delete_complete, get_attr(:stack_name))
        end

        # Attribute helpers
        no_commands do
          class << self
            attr_accessor :_attr
            def set_attr(name, value)
              self._attr ||= {
                tags: {},
                parameters: {}
              }
              self._attr[name] = value
            end
          end

          def get_attr(name)
            self.class._attr[name] if self.class._attr.key? name
          end
        end

        # AWS helpers
        no_commands do
          include Shelter::CLI::Helpers::CloudFormation

          def meta
            stack_meta(
              get_attr(:tags).merge(
                client: get_attr(:meta)[:client],
                application: get_attr(:meta)[:application]
              ),
              type: get_attr(:meta)[:type]
            )
          end
        end
      end
    end
  end
end
