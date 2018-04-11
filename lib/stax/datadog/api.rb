require 'dogapi'

module Stax
  module Datadog

    class Api
      class << self

        def client
          # ensure_env('DATADOG_API_KEY', 'DATADOG_APP_KEY')
          @_client ||= Dogapi::Client.new(ENV['DATADOG_API_KEY'], ENV['DATADOG_APP_KEY'])
        end

        def dashboards
          @_dashboards ||= client.get_dashboards[1]['dashes']
        end

        ## find all dashboards with title or id
        def find_dashboards(x)
          dashboards.select do |t|
            (t['title'] == x) || (t['id'] == x)
          end
        end

        def dashboard_exists?(name)
          !find_dashboards(name).empty?
        end

        def handle_response(resp)
          if resp[0].match(/^2\d\d$/)
            resp[1]
          else
            warn(resp[1].fetch('errors', 'datadog error'))
            nil
          end
        end

        def create_dashboard(*args)
          if dashboard_exists?(args[0])
            warn("Dashboard #{args[0]} already exists")
          else
            handle_response(client.create_dashboard(*args))
          end
        end

        def update_dashboard(*args)
          if dashboard_exists?(args[0])
            id = find_dashboards(args[0]).first['id']
            handle_response(client.update_dashboard(id, *args))
          else
            warn("Dashboard #{args[0]} does not exist")
          end
        end

        def delete_dashboards(name)
          find_dashboards(name).each do |dashboard|
            id = dashboard['id']
            warn("Deleting dashboard #{name} (#{id})")
            handle_response(client.delete_dashboard(id))
          end
        end

      end
    end

  end
end