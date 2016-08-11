require 'assert'
require 'dk-pkg'

module Dk::Pkg

  class UnitTests < Assert::Context
    desc "Dk::Pkg"
    setup do
      @module = Dk::Pkg
    end
    subject{ @module }

    should "know its param names" do
      assert_equal 'dk_pkg_manifest_path',  MANIFEST_PATH_PARAM_NAME
      assert_equal 'dk_pkg_manifest_mode',  MANIFEST_MODE_PARAM_NAME
      assert_equal 'dk_pkg_manifest_owner', MANIFEST_OWNER_PARAM_NAME
      assert_equal 'dk_pkg_installed_pkgs', INSTALLED_PKGS_PARAM_NAME
    end

    should "know its manifest separator" do
      assert_equal "\n", MANIFEST_SEPARATOR
    end

  end

end
