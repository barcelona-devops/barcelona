module Barcelona
  module Plugins
    class DatadogPlugin < Base
      def on_container_instance_user_data(_instance, user_data)
        user_data.run_commands += [
          agent_command
        ]

        user_data
      end

      private

      def agent_command
        ["DOCKER_CONTENT_TRUST=1",
         "docker", "run", "-d",
         "--name", "datadog-agent",
         "-h", "`hostname`",
         "-v", "/var/run/docker.sock:/var/run/docker.sock:ro",
         "-v", "/proc/:/host/proc/:ro",
         "-v", "/cgroup/:/host/sys/fs/cgroup:ro",
         "-v", "/opt/datadog-agent/run:/opt/datadog-agent/run:rw",
         "-e", "DD_API_KEY=#{api_key}",
         "-e", "DD_LOGS_ENABLED=true",
         "-e", "DD_AC_INCLUDE='name:ecs-agent name:datadog-agent'",
         *tags,
         "datadog/agent:latest"
        ].flatten.compact.join(" ")
      end

      def tags
        ["-e", %Q{DD_TAGS="barcelona,barcelona-dd-agent,district:#{district.name}"}]
      end

      def api_key
        attributes["api_key"]
      end
    end
  end
end
