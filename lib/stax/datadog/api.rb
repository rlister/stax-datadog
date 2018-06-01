require 'dogapi'

module Stax
  module Datadog

    class Api
      class << self

        def client
          @_client ||= Dogapi::Client.new(ENV['DATADOG_API_KEY'], ENV['DATADOG_APP_KEY'])
        rescue RuntimeError => e
          abort("Stax::Datadog: #{e.message}")
        end

        def lists
          handle_response(client.get_all_dashboard_lists)['dashboard_lists']
        end

        ## find all lists with name or id
        def find_lists(x)
          lists.select do |l|
            (l['name'] == x) || (l['id'] == x)
          end
        end

        def list_exists?(name)
          !find_lists(name).empty?
        end

        ## create list, unless there is already a list with this name
        def create_or_get_list(name)
          list = find_lists(name)&.first || handle_response(client.create_dashboard_list(name))
          get_list(list['id'])
        end

        def get_list(id)
          handle_response(client.get_dashboard_list(id))
        end

        def get_list_items(id)
          handle_response(client.get_items_of_dashboard_list(id))
        end

        def add_to_list(id, dashboards)
          resp = client.add_items_to_dashboard_list(id, Array(dashboards))
          handle_response(resp)
        end

        def delete_from_list(id, dashboards)
          resp = client.delete_items_from_dashboard_list(id, Array(dashboards))
          handle_response(resp)
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
            handle_response(client.create_dashboard(*args)).dig('dash', 'id')
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