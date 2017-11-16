module Harbor
  module Ansible
    # Ansible Inventory representation
    class Inventory
      def initialize
        @inv = {}
      end

      def add_group_vars(group, vars)
        @inv[group] ||= { hosts: [], vars: {} }
        @inv[group][:vars].merge! vars
      end

      def add_server(group, ip, vars: {})
        @inv[group] ||= { hosts: [], vars: {} }

        @inv[group][:hosts] << ip
        #@inv[group][:vars] = { ansible_host: ip }.merge(vars)
      end

      def to_json
        @inv.to_json
      end
    end
  end
end
