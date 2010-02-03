
# add sort-ability to symbol so we can order keys array in hash for test-ability 
class Symbol
  include Comparable

  def <=>(other)
    self.to_s <=> other.to_s
  end
end


class ConfiguratorHelper
  
  constructor :configurator_validator
    
  def validate_required_sections(config)
    validation = []
    validation << @configurator_validator.exists?(config, :project)
    validation << @configurator_validator.exists?(config, :paths)
    validation << @configurator_validator.exists?(config, :tools)

    return false if (validation.include?(false))
    return true
  end

  def validate_required_section_values(config)
    validation = []
    validation << @configurator_validator.exists?(config, :project, :build_root)
    validation << @configurator_validator.exists?(config, :paths, :test)
    validation << @configurator_validator.exists?(config, :paths, :source)
    validation << @configurator_validator.exists?(config, :tools, :test_compiler)
    validation << @configurator_validator.exists?(config, :tools, :test_linker)
    validation << @configurator_validator.exists?(config, :tools, :test_fixture)

    return false if (validation.include?(false))
    return true
  end

  def validate_paths(config)
    validation = []

    validation << @configurator_validator.validate_paths(config, :project, :build_root) 

    config[:paths].keys.sort.each do |key|
      validation << @configurator_validator.validate_paths(config, :paths, key)
    end

    extender_base_path = config[:extenders][:base_path]
    validation << @configurator_validator.validate_path( extender_base_path, :extenders, :base_path )
    config[:extenders][:enabled].sort.each do |extender|
      validation << @configurator_validator.validate_path( File.join(extender_base_path, extender), :extenders, :enabled, extender.to_sym )
    end

    return false if (validation.include?(false))
    return true
  end
  
  def validate_tools(config)
    validation = []

    config[:tools].keys.sort.each do |key|
      validation << @configurator_validator.exists?(config, :tools, key, :executable)
      validation << @configurator_validator.validate_filepath(config, :tools, key, :executable)    
    end

    return false if (validation.include?(false))
    return true
  end
  
end