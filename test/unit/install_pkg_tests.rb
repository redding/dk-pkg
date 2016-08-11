require 'assert'
require 'dk-pkg/install_pkg'

require 'dk/task'
require 'much-plugin'
require 'dk-pkg/constants'
require 'dk-pkg/validate'

module Dk::Pkg::InstallPkg

  class UnitTests < Assert::Context
    include Dk::Pkg::Validate::TestHelpers

    desc "Dk::Pkg::InstallPkg"
    subject{ Dk::Pkg::InstallPkg }

    should "use much-plugin" do
      assert_includes MuchPlugin, subject
    end

  end

  class MixinTests < UnitTests
    desc "mixin"
    setup do
      @task_class = Class.new{ include Dk::Pkg::InstallPkg }
    end
    subject{ @task_class }

    should "be a Dk::Task" do
      assert_includes Dk::Task, subject
    end

    should "run the Validate task as a before callback" do
      assert_equal [Dk::Pkg::Validate], subject.before_callback_task_classes
    end

  end

  class InitTests < MixinTests
    desc "when init"
    setup do
      @task_class.class_eval do
        def run!
          install_pkg params['pkg-name'] do
            set_param 'install-pkg-yielded', true
          end
        end
      end
      @params['pkg-name']            = Factory.string
      @params['install-pkg-yielded'] = false

      @runner = test_runner(@task_class, :params => @params)
    end
    subject{ @runner }

    should "provide an install pkg helper" do
      subject.run

      assert_true subject.params['install-pkg-yielded']
      # there will always be +1 because of the Validate task being run
      assert_equal 2, subject.runs.size
      tee_cmd = subject.runs.last
      assert_equal "tee #{@dk_pkg_manifest_path}", tee_cmd.cmd_str

      exp_pkgs = [@params['pkg-name']]
      assert_equal Dk::Pkg::Manifest.serialize(exp_pkgs), tee_cmd.run_input

      assert_equal exp_pkgs, subject.params[Dk::Pkg::INSTALLED_PKGS_PARAM_NAME]
    end

    should "not yield or run any commands if the pkg is already installed" do
      @params[Dk::Pkg::INSTALLED_PKGS_PARAM_NAME] << @params['pkg-name']
      runner = test_runner(@task_class, :params => @params)
      runner.run

      assert_false runner.params['install-pkg-yielded']
      # there will always be +1 because of the Validate task being run
      assert_equal 1, runner.runs.size
    end

    should "complain if passed invalid args" do
      assert_raises(ArgumentError) do
        subject.task.instance_eval{ install_pkg([nil, ''].choice){ } }
      end
      assert_raises(ArgumentError) do
        subject.task.instance_eval{ install_pkg(Factory.string) }
      end
    end

  end

end
