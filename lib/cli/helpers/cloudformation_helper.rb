# frozen_string_literal: true

module Shelter
  module CLI
    module Helpers
      # Mixin module for CloudFormation
      module CloudFormation
        def cf_client
          @cf_client ||= Aws::CloudFormation::Client.new(
            credentials: Aws::Credentials.new(
              ENV.fetch('AWS_ACCESS_KEY_ID'),
              ENV.fetch('AWS_SECRET_ACCESS_KEY')
            )
          )
        end

        def wait_until(status, stack_name)
          puts "Waiting for '#{status}' on '#{stack_name}'..."
          cf_client.wait_until(
            status,
            stack_name: stack_name
          )
        end

        def display_stack_resource(r)
          puts "Resource ID: #{r.physical_resource_id}"
          puts "  Resource Type: #{r.resource_type}"
          puts "  Resource Status: #{r.resource_status}"
        end

        def display_stack_output(out)
          puts out.description unless out.description.nil?
          puts "#{out.output_key}: #{out.output_value}"
        end

        def stack_meta(res)
          tags = []

          res.each do |key, value|
            tags << { key: key.to_s, value: value.to_s }
          end

          tags << { key: 'type', value: 'resource' }

          tags
        end

        def stack_params(res)
          params = []

          res.each do |key, value|
            params << { parameter_key: key.to_s, parameter_value: value.to_s }
          end

          params
        end
      end
    end
  end
end
