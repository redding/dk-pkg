require 'dk/task'
require 'much-plugin'
require 'dk-pkg/constants'
require 'dk-pkg/validate'

module Dk::Pkg

  module InstallPkg
    include MuchPlugin

    WRITE_MANIFEST_CMD_STR_PROC = proc{ |manifest_path| "tee #{manifest_path}" }

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
        cmd!(
          WRITE_MANIFEST_CMD_STR_PROC.call(params[MANIFEST_PATH_PARAM_NAME]),
          serialized_pkgs
        )
        set_param INSTALLED_PKGS_PARAM_NAME, Manifest.deserialize(serialized_pkgs)
      end

    end

    module TestHelpers
      include MuchPlugin

      plugin_included do
        include Dk::Pkg::Validate::TestHelpers
        include InstanceMethods

      end

      module InstanceMethods

        def assert_dk_pkg_installed(test_runner, pkg_name)
          assert_includes pkg_name, test_runner.params[INSTALLED_PKGS_PARAM_NAME]
        end

        def non_dk_install_pkg_runs(test_runner)
          manifest_path          = test_runner.params[MANIFEST_PATH_PARAM_NAME]
          write_manifest_cmd_str = WRITE_MANIFEST_CMD_STR_PROC.call(manifest_path)

          test_runner.runs.reject do |run|
            validate_task_run  = run.kind_of?(Dk::TaskRun) &&
                                 run.task_class == Dk::Pkg::Validate
            write_manifest_cmd = run.kind_of?(Dk::Local::CmdSpy) &&
                                 run.cmd_str == write_manifest_cmd_str
            validate_task_run || write_manifest_cmd
          end
        end

      end

    end

  end

end
