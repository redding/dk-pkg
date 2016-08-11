require 'assert/factory'
require 'dk-pkg/constants'

module Factory
  extend Assert::Factory

  def self.manifest(installed_pkgs = nil)
    installed_pkgs ||= Factory.installed_pkgs
    installed_pkgs.join(Dk::Pkg::MANIFEST_SEPARATOR)
  end

  def self.installed_pkgs
    Factory.integer(3).times.map{ Factory.string }
  end

end
