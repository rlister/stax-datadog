module Stax
  module Datadog
    class Cmd < Base

      no_commands do

        ## if this is defined, dashboard will be added to this list
        def list_name
          app_name
        end

        def dashboard_name
          app_name + '-' + branch_name
        end

        def dashboard_description
          'created by stax'
        end

        def graph_definitions
          []
        end

        def template_variables
          []
        end
      end

      desc 'list', 'dashboard list'
      def list
        Datadog::Api.find_lists(list_name).each do |list|
          debug("Datadog list #{list['name']} (#{list['id']})")
          print_table Datadog::Api.get_list_items(list['id']).fetch('dashboards', []).map { |d|
            [d['title'], d['id'], d['modified']]
          }
        end
      end

      desc 'create', 'create dashboard'
      def create
        debug("Creating datadog dashboard #{dashboard_name}")
        id = Datadog::Api.create_dashboard(
          dashboard_name,
          dashboard_description,
          graph_definitions,
          template_variables,
        )

        ## add it to list (create as needed)
        list = Datadog::Api.create_or_get_list(list_name)
        Datadog::Api.add_to_list(list['id'], [{type: :custom_timeboard, id: id}])
      end

      desc 'update', 'update dashboard'
      def update
        debug("Updating datadog dashboard #{dashboard_name}")
        Datadog::Api.update_dashboard(
          dashboard_name,
          dashboard_description,
          graph_definitions,
          template_variables,
        )
      end

      desc 'delete [TITLE/ID]', 'delete timeboards'
      def delete(title_or_id = nil)
        if yes?("Delete dashboards with name #{dashboard_name}?", :yellow)
          debug("Deleting datadog dashboard #{dashboard_name}")
          Datadog::Api.delete_dashboards(dashboard_name)
        end
      end

    end
  end
end