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
      exp = "tee #{@params[Dk::Pkg::MANIFEST_PATH_PARAM_NAME]}"
      assert_equal exp, tee_cmd.cmd_str

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

  class TestHelpersTests < UnitTests
    desc "TestHelpers"
    setup do
      @task_class = Class.new do
        include Dk::Pkg::InstallPkg

        def run!
          params['pkgs'].each do |(pkg_name, pkg_cmd)|
            install_pkg(pkg_name){ cmd(pkg_cmd) }
          end
          run_task TestTask
        end
      end

      # use an array of tuples so we don't have to worry about hash randomly
      # ordering its key/values when testing
      @params['pkgs'] = Factory.integer(3).times.map do
        [Factory.string, Factory.string]
      end
      @runner = test_runner(@task_class, :params => @params)
      @runner.run

      @context_class = Class.new do
        def self.setup(&block); end # needed for `Dk::Pkg::Validate::TestHelpers`
        include Dk::Pkg::InstallPkg::TestHelpers

        def initialize(assert_context)
          @assert_context = assert_context
        end

        # needed to test `assert_dk_pkg_installed`
        def assert_includes(*args)
          @assert_context.assert_includes(*args)
        end
      end
      @context = @context_class.new(self)
    end
    subject{ @context }

    should have_imeths :assert_dk_pkg_installed, :non_dk_install_pkg_runs

    should "use much-plugin" do
      assert_includes MuchPlugin, Dk::Pkg::InstallPkg::TestHelpers
    end

    should "include dk-pkg Validate test helpers" do
      assert_includes Dk::Pkg::Validate::TestHelpers, @context_class
    end

    should "provide a helper for asserting a pkg was installed" do
      @params['pkgs'].each do |pkg_name, pkg_cmd|
        subject.assert_dk_pkg_installed(@runner, pkg_name)
      end
    end

    should "know how to select non dk-pkg install pkg runs" do
      runs = subject.non_dk_install_pkg_runs(@runner)
      assert_not_equal runs, @runner.runs
      assert_equal @params['pkgs'].size + 1, runs.size
      cmd_runs = runs[0, @params['pkgs'].size]
      assert_equal @params['pkgs'].map(&:last), cmd_runs.map(&:cmd_str)
      assert_equal TestTask, runs.last.task_class
    end

  end

  TestTask = Class.new{ include Dk::Task }

end
