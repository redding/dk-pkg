require 'assert'
require 'dk-pkg/manifest'

require 'dk-pkg/constants'

module Dk::Pkg::Manifest

  class UnitTests < Assert::Context
    desc "Dk::Pkg::Manifest"
    setup do
      @pkgs = Factory.manifest_pkgs
    end
    subject{ Dk::Pkg::Manifest }

    should have_imeths :serialize, :deserialize

    should "know how to serialize and deserialize" do
      exp = @pkgs.join(Dk::Pkg::MANIFEST_SEPARATOR)
      serialized_pkgs = subject.serialize(@pkgs)
      assert_equal exp, serialized_pkgs
      assert_equal @pkgs, subject.deserialize(serialized_pkgs)
    end

    should "clean pkg names using serialize/deserialize" do
      valid_pkgs      = Factory.manifest_pkgs.shuffle # randomize their order
      non_string_pkgs = [Factory.integer, Factory.boolean, Factory.float]
      duplicate_pkg   = Factory.string
      pkgs = valid_pkgs +
             non_string_pkgs +                        # add non strings
             ([duplicate_pkg] * Factory.integer(3)) + # add duplicates
             ([nil] * Factory.integer(3)) +           # add `nil` packages
             ([""] * Factory.integer(3))              # add empty string packages
      serialized_pkgs = pkgs.shuffle.join(Dk::Pkg::MANIFEST_SEPARATOR)

      exp_pkgs            = (valid_pkgs + non_string_pkgs + [duplicate_pkg]).map(&:to_s).sort
      exp_serialized_pkgs = exp_pkgs.join(Dk::Pkg::MANIFEST_SEPARATOR)

      assert_equal exp_serialized_pkgs, subject.serialize(pkgs)
      assert_equal exp_pkgs,            subject.deserialize(serialized_pkgs)
    end

    should "handle special cases using serialize/deserialize" do
      # a single item
      pkg = Factory.string
      assert_equal pkg,   subject.serialize([pkg])
      assert_equal [pkg], subject.deserialize(pkg)

      assert_equal "", subject.serialize([])
      assert_equal [], subject.deserialize("")
    end

    should "complain if serialize/deserialize is passed invalid args" do
      assert_raises(ArgumentError){ subject.serialize(nil) }
      assert_raises(ArgumentError){ subject.serialize(Factory.string) }

      assert_raises(ArgumentError){ subject.deserialize(nil) }
      array = Factory.integer(3).times.map{ Factory.string }
      assert_raises(ArgumentError){ subject.deserialize(array) }
    end

  end

end
