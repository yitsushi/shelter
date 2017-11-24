# frozen_string_literal: true

require 'thor'
require 'yaml'

module Shelter
  module CLI
    module Command
      # Resource subcommand for Shelter
      class Resource < Thor
        desc 'list', 'List all managed resources'
        def list
          Dir.glob("#{App.config.resource_directory}/*.yaml").each do |res|
            puts File.basename(res, '.yaml')
          end
        end

        desc 'status <resource-name>', 'Resource status'
        def status(resource_name)
          resource = read_resource(resource_name)

          stack = cf_client.describe_stacks(
            stack_name: resource['name']
          ).stacks.first

          cf_client.describe_stack_resources(
            stack_name: stack.stack_name
          ).stack_resources.each { |r| display_stack_resource(r) }
        rescue Aws::CloudFormation::Errors::ValidationError
          puts "#{resource_name} does not exist"
        end

        desc 'outputs <resource-name>', 'Display resource output'
        def output(resource_name)
          resource = read_resource(resource_name)

          stack = cf_client.describe_stacks(
            stack_name: resource['name']
          ).stacks.first

          stack.outputs.each { |out| display_stack_output(out) }
        end

        desc 'update <resource-name>', 'Update a specific resource'
        def update(resource_name)
          res = read_resource(resource_name)
          cf_client.update_stack(
            stack_name: res['name'], capabilities: res['capabilities'],
            template_body: read_template(res['template']),
            tags: res['tags'], parameters: res['parameters']
          )
          wait_until(:stack_delete_complete, resource['name'])
        rescue Aws::CloudFormation::Errors::ValidationError => e
          puts e.message
        end

        desc 'delete <resource-name>', 'Delete a specific resource'
        def delete(resource_name)
          resource = read_resource(resource_name)
          cf_client.delete_stack(stack_name: resource['name'])
          wait_until(:stack_delete_complete, resource['name'])
        end

        desc 'create <resource-name>', 'Create a specific resource'
        def create(resource_name)
          res = read_resource(resource_name)
          cf_client.create_stack(
            stack_name: res['name'], capabilities: res['capabilities'],
            template_body: read_template(res['template']),
            tags: res['tags'], parameters: res['parameters']
          )
          wait_until(:stack_create_complete, res['name'])
        end

        no_commands do
          include Shelter::CLI::Helpers::CloudFormation

          def read_resource(name)
            res = YAML.load_file(
              "#{App.config.resource_directory}/#{name}.yaml"
            )
            raise 'No name specified...' if res['name'].nil?

            res['name'] = "res-#{res['name']}"
            res['capabilities'] ||= []
            res['tags'] = stack_meta(res['tags'] || {})
            res['parameters'] = stack_params(res['parameters'] || {})
            res
          end

          def resource_template_dir
            "#{App.config.resource_directory}/templates"
          end

          def read_template(name)
            File.open("#{resource_template_dir}/#{name}.yaml").read
          end
        end
      end
    end
  end
end
