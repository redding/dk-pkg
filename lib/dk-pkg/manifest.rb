require 'dk-pkg/constants'

module Dk::Pkg

  module Manifest

    def self.serialize(pkgs)
      raise ArgumentError, "pkgs must be an array" if !pkgs.kind_of?(Array)
      sanitize_array(pkgs).join(MANIFEST_SEPARATOR)
    end

    def self.deserialize(serialized_pkgs)
      if !serialized_pkgs.kind_of?(String)
        raise ArgumentError, "serialized pkgs must be a string"
      end
      sanitize_array(serialized_pkgs.split(MANIFEST_SEPARATOR))
    end

    private

    def self.sanitize_array(array)
      array.compact.uniq.map(&:to_s).reject(&:empty?).sort
    end

  end

end
