require 'dk/task'
require 'dk-pkg/constants'

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
      manifest = cmd!("cat #{params[MANIFEST_PATH_PARAM_NAME]}").stdout
      set_param INSTALLED_PKGS_PARAM_NAME, manifest.split(MANIFEST_SEPARATOR)
    end

    module TestHelpers
      include MuchPlugin

      plugin_included do
        include Dk::Task::TestHelpers

        setup do
          @dk_pkg_manifest_path  ||= Factory.file_path
          @dk_pkg_installed_pkgs ||= []

          @params ||= {}
          @params[MANIFEST_PATH_PARAM_NAME]  ||= @dk_pkg_manifest_path
          @params[INSTALLED_PKGS_PARAM_NAME] ||= @dk_pkg_installed_pkgs
        end

      end

    end

  end

end
