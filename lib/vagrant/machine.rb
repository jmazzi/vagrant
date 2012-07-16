require "log4r"

module Vagrant
  # This represents a machine that Vagrant manages. This provides a singular
  # API for querying the state and making state changes to the machine, which
  # is backed by any sort of provider (VirtualBox, VMWare, etc.).
  class Machine
    # The box that is backing this machine.
    #
    # @return [Box]
    attr_reader :box

    # Configuration for the machine.
    #
    # @return [Object]
    attr_reader :config

    # The environment that this machine is a part of.
    #
    # @return [Environment]
    attr_reader :env

    # Name of the machine. This is assigned by the Vagrantfile.
    #
    # @return [String]
    attr_reader :name

    # Initialize a new machine.
    #
    # @param [String] name Name of the virtual machine.
    # @param [Class] provider The provider backing this machine. This is
    #   currently expected to be a V1 `provider` plugin.
    # @param [Object] config The configuration for this machine.
    # @param [Box] box The box that is backing this virtual machine.
    # @param [Environment] env The environment that this machine is a
    #   part of.
    def initialize(name, provider_cls, config, box, env)
      @name     = name
      @box      = box
      @config   = config
      @env      = env
      @provider = provider_cls.new(self)
    end

    # This calls an action on the provider. The provider may or may not
    # actually implement the action.
    #
    # @param [Symbol] name Name of the action to run.
    def action(name)
      # Get the callable from the provider.
      callable = @provider.action(name)

      # If this action doesn't exist on the provider, then an exception
      # must be raised.
      if callable.nil?
        raise Errors::UnimplementedProviderAction,
          :action => name,
          :provider => @provider.to_s
      end

      # Run the action with the action runner on the environment
      @env.action_runner.run(callable, :machine => self)
    end

    # Returns the state of this machine. The state is queried from the
    # backing provider, so it can be any arbitrary symbol.
    #
    # @return [Symbol]
    def state
      @provider.state
    end
  end
end