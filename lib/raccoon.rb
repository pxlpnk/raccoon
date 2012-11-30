require "raccoon/version"

require 'celluloid'
require 'celluloid/io'
require 'xmpp4r'
require 'yaml'

class TcpServer
  include Celluloid::IO
  include Celluloid::Logger


  def initialize(config, jabber)
    host = config["host"]
    port = config["port"]

    info "*** Starting server on #{host}:#{port}"

    @jabber = jabber
    # Since we included Celluloid::IO, we're actually making a
    # Celluloid::IO::TCPServer here
    @server = TCPServer.new(host, port)
    run!
  end

  def finalize
    @server.close if @server
  end

  def run
    loop { handle_connection! @server.accept }
  end

  def handle_connection(socket)
    _, port, host = socket.peeraddr
    debug  "*** Received connection from #{host}:#{port}"
    loop { @jabber.send_msg socket.readpartial(4096) }
  rescue EOFError
    debug "*** #{host}:#{port} disconnected"
    socket.close
  end
end


class JabberClient
  include Celluloid
  include Celluloid::Logger

  attr_accessor :client, :recipient

  def initialize(config)
    debug "Initializing jabber connection"

    self.recipient = config["recipient"]
    self.client = Jabber::Client.new(Jabber::JID.new(config["jabber_id"]))
    self.client.connect
    self.client.auth(config["password"])

    self.client.send(Jabber::Presence.new.set_show(:chat).set_status('Forwarding the TCP for you i am!'))
  end


  def send_msg(message)
    debug message
    answer = Jabber::Message.new(self.recipient)
    answer.type = :chat
    answer.body = message

    self.client.send(answer)
  end

end


module Raccoon
  Celluloid.logger.level = Logger::WARN
  def self.run(config)
    jabber_config = config["jabber"]
    tcp_config = config["tcp"]

    jabber_supervisor = JabberClient.supervise(jabber_config)

    jabber = jabber_supervisor.actors.first
    supervisor = TcpServer.supervise(tcp_config, jabber)

    jabber.send_msg("Reporting for duty!")

    trap 'INT' do
      supervisor.terminate
      jabber.terminate
      exit
    end
    sleep
  end
end
