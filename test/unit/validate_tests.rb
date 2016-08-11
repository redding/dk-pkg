require 'assert'
require 'dk-pkg/validate'

require 'dk/task'
require 'dk-pkg/constants'

class Dk::Pkg::Validate

  class UnitTests < Assert::Context
    desc "Dk::Pkg::Validate"
    setup do
      @task_class = Dk::Pkg::Validate
    end
    subject{ @task_class }

    should "be a Dk::Task" do
      assert_includes Dk::Task, subject
    end

    should "know its description" do
      exp = "(dk-pkg) validate the required dk-pkg params"
      assert_equal exp, subject.description
    end

    should "only run once" do
      assert_true subject.run_only_once
    end

  end

  class RunSetupTests < UnitTests
    include Dk::Task::TestHelpers

    desc "when run"
    setup do
      @manifest_path  = Factory.file_path
      @installed_pkgs = Factory.installed_pkgs

      @exp_cat_cmd = "cat #{@manifest_path}"

      @params = {
        Dk::Pkg::MANIFEST_PATH_PARAM_NAME => @manifest_path
      }
    end
    subject{ @runner }

    private

    def stub_cat_manifest_file_cmd(runner, manifest = nil)
      manifest ||= Factory.manifest(@installed_pkgs)
      runner.stub_cmd(@exp_cat_cmd){ |s| s.stdout = manifest }
    end

  end

  class RunTests < RunSetupTests
    setup do
      @runner = test_runner(@task_class, :params => @params)
      stub_cat_manifest_file_cmd(@runner)
      @runner.run
    end

    should "parse the manifest file and set the installed pkgs param" do
      assert_equal 2, subject.runs.size

      touch_cmd, cat_cmd = subject.runs
      assert_equal "touch #{@manifest_path}", touch_cmd.cmd_str
      assert_equal @exp_cat_cmd,              cat_cmd.cmd_str

      exp = @installed_pkgs
      assert_equal exp, subject.params[Dk::Pkg::INSTALLED_PKGS_PARAM_NAME]
    end

  end

  class RunWithEmptyManifestTests < RunSetupTests
    desc "and the manifest is empty"
    setup do
      @runner = test_runner(@task_class, :params => @params)
      stub_cat_manifest_file_cmd(@runner, "")
      @runner.run
    end

    should "parse the manifest file and set the installed pkgs param" do
      assert_equal [], subject.params[Dk::Pkg::INSTALLED_PKGS_PARAM_NAME]
    end

  end

  class RunWithoutManifestPathTests < RunSetupTests
    desc "and the manifest path param isn't set"
    setup do
      @params[Dk::Pkg::MANIFEST_PATH_PARAM_NAME] = [nil, ''].sample
    end

    should "complain about the param not being set" do
      runner = test_runner(@task_class, :params => @params)
      assert_raises(ArgumentError){ runner.run }
    end

  end

  class TestHelpersTests < UnitTests
    desc "TestHelpers"
    setup do
      @context_class = Class.new do
        def self.setup_blocks; @setup_blocks ||= []; end
        def self.setup(&block)
          self.setup_blocks << block
        end
        include Dk::Pkg::Validate::TestHelpers
        attr_reader :dk_pkg_manifest_path, :dk_pkg_installed_pkgs
        attr_reader :params
        def initialize
          self.class.setup_blocks.each{ |b| self.instance_eval(&b) }
        end
      end
      @context = @context_class.new
    end
    subject{ @context }

    should "use much-plugin" do
      assert_includes MuchPlugin, @context_class
    end

    should "setup the ivars and params the validate task does" do
      exp = subject.dk_pkg_manifest_path
      assert_equal exp, subject.params[Dk::Pkg::MANIFEST_PATH_PARAM_NAME]

      exp = subject.dk_pkg_installed_pkgs
      assert_equal exp, subject.params[Dk::Pkg::INSTALLED_PKGS_PARAM_NAME]
    end

  end

end
