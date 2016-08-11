require 'dk/task'
require 'much-plugin'
require 'dk-pkg/constants'
require 'dk-pkg/validate'

module Dk::Pkg

  module InstallPkg
    include MuchPlugin

    plugin_included do
      include Dk::Task
      include InstanceMethods

      before Dk::Pkg::Validate

    end

    module InstanceMethods

      private

      def install_pkg(name)
        raise(ArgumentError, "a pkg name must be provided") if name.to_s.empty?
        raise(ArgumentError, "no block given") unless block_given?

        if !params[INSTALLED_PKGS_PARAM_NAME].include?(name)
          yield
          dk_pkg_write_pkg_to_manifest(name)
        else
          log_info "#{name.inspect} has already been installed"
        end
      end

      def dk_pkg_write_pkg_to_manifest(name)
        pkgs = params[INSTALLED_PKGS_PARAM_NAME] + [name]
        serialized_pkgs = Manifest.serialize(pkgs)
        cmd!("tee #{params[MANIFEST_PATH_PARAM_NAME]}", serialized_pkgs)
        set_param INSTALLED_PKGS_PARAM_NAME, Manifest.deserialize(serialized_pkgs)
      end

    end

  end

end
