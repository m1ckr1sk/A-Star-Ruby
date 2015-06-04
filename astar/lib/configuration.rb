####################
## Configuration  ##
####################

# Configuration, to be more DRY
# add connection urls here
class Configuration
  def self.rabbitmq_url
    command_line_url || boxen_url || docker_url || default_url
  end

  def self.route_template_location
    route_template_location_env || route_template_location_default
  end

  def self.route_template_location_env
    ENV['TEMPLATE_FILE_DIR']
  end

  def self.route_template_location_default
    "./"
  end

  def self.default_url
    "amqp://guest:guest@localhost:5672"
  end

  def self.docker_url
    amqp_port_address = ENV['AMQ_PORT_5672_TCP_ADDR']
    amqp_port_address ? "amqp://guest:guest@#{amqp_port_address}" : nil
  end

  def self.boxen_url
    ENV['BOXEN_RABBITMQ_URL']
  end
  
  def self.command_line_url
    ARGV[0]
  end
end
