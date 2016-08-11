require 'assert/factory'
require 'dk-pkg/manifest'

module Factory
  extend Assert::Factory

  def self.manifest_pkgs
    Factory.integer(3).times.map{ Factory.string }.sort
  end

end
