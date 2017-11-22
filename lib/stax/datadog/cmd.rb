module Stax
  module Datadog
    class Cmd < Base

      no_commands do
        def dashboard_name
          app_name + '-' + branch_name
        end

        def dashboard_description
          'created by stax test2'
        end

        def graph_definitions
          [
            {
              definition: {
                events: [],
                requests: [
                  {q: 'avg:system.mem.free{*}'}
                ],
                viz: :timeseries
              },
              title: 'Average Memory Free'
            }
          ]
        end

        def template_variables
          []
        end
      end

      desc 'create', 'create dashboard'
      def create
        Datadog::Api.create_dashboard(
          dashboard_name,
          dashboard_description,
          graph_definitions,
          template_variables,
        )
      end

      desc 'update', 'update dashboard'
      def update
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
          Datadog::Api.delete_dashboards(dashboard_name)
        end
      end

    end
  end
end