require 'dk/task'
require 'dk-pkg/constants'
require 'dk-pkg/manifest'

module Dk::Pkg

  class Validate
    include Dk::Task

    desc "(dk-pkg) validate the required dk-pkg params"

    run_only_once true

    def run!
      # validate that a manifest path has been set, so we can parse it
      if params[MANIFEST_PATH_PARAM_NAME].to_s.empty?
        raise ArgumentError, "no #{MANIFEST_PATH_PARAM_NAME.inspect} param set"
      end

      cmd! "touch #{params[MANIFEST_PATH_PARAM_NAME]}"
      serialized_pkgs = cmd!("cat #{params[MANIFEST_PATH_PARAM_NAME]}").stdout
      set_param INSTALLED_PKGS_PARAM_NAME, Manifest.deserialize(serialized_pkgs)
    end

    module TestHelpers
      include MuchPlugin

      plugin_included do
        include Dk::Task::TestHelpers

        setup do
          @dk_pkg_installed_pkgs ||= []

          @params ||= {}
          @params[MANIFEST_PATH_PARAM_NAME]  ||= Factory.file_path
          @params[INSTALLED_PKGS_PARAM_NAME] ||= @dk_pkg_installed_pkgs
        end

      end

    end

  end

end
