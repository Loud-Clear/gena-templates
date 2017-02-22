class String
  def underscore
    self.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
  end
end

module Generate

  class Mapping < BaseTemplate

    def self.register_options(opts, options)
      opts.on('--model [ClassName]', String, 'mapping | Specify model class name') { |f| options[:model_class_name] = f }

    end

    def validate_type_config
      if self.type_config == nil || self.type_config['path'] == nil
        puts "\nError: Please specify 'path' parameter in 'generate.plist' for 'mapping' template"
        exit
      end
    end

    def sources_path
      validate_type_config
      "#{self.type_config['path']}/#{options[:scope]}"
    end

    def http_method
      return options[:method] unless options[:method].nil?
      downcase_name = options[:name].downcase
      return :POST if downcase_name.include_one_of? ['post', 'create']
      return :GET if downcase_name.include_one_of? ['get', 'read']
      return :PUT if downcase_name.include_one_of? ['put', 'update']
      return :DELETE if downcase_name.include_one_of? ['delete', 'remove']
      return :GET
    end

    def class_name
      options[:model_class_name] || "#{config['prefix']}#{options[:name].downcase.capitalize_first}"
    end


    def path_to_class_header
      sources_dir = self.config['sources_dir']
      source_path = `find ./#{sources_dir} -name "#{class_name}.h"`
      source_path.gsub!(/\s+/, ' ').strip!
      source_path
    end

    def header_content
      unless path_to_class_header
        return ''
      end
      content = IO.read(path_to_class_header)

      groups = content.match(/@interface\s*?#{class_name}.*?\n(.*)/m).captures

      groups.first
    end

    def header_properties
      header = header_content
      properties = []
      header.scan(/@property.*?(?<name>[\w]*);\n/m).each do |match|
        properties << match.first
      end
      return properties
    end


    def template_source_files
      prefix = config['prefix']
      name = options[:name].downcase.capitalize_first

      file_name = "#{prefix}#{name}Mapping"

      files = []
      files << {
          'name' => 'Mapping.h',
          'path' => 'Code/mapping.h.liquid',
          'custom_name' => "#{file_name}.h"
      }
      files << {
          'name' => 'Mapping.m',
          'path' => 'Code/mapping.m.liquid',
          'custom_name' => "#{file_name}.m"
      }
      files << {
          'name' => 'Mapping.request.json',
          'path' => 'Code/mapping.json.liquid',
          'custom_name' => "#{file_name}.request.json",
          'is_resource' => true
      }
      files << {
          'name' => 'Mapping.response.json',
          'path' => 'Code/mapping.json.liquid',
          'custom_name' => "#{file_name}.response.json",
          'is_resource' => true
      }
      files
    end


    def generate_properties_parsing
      path = 'Templates/default/Code/mapping.m.liquid'
      template_content = IO.read(path)

      mapping = ''
      header_properties.each do |name|
        mapping << "    instance.#{name} = responseObject[@\"#{name.underscore}\"];\n"
      end
      template_content.gsub!('{{ properties_parsing }}', mapping)

      composing = ''
      header_properties.each do |name|
        composing << "    requestDict[@\"#{name.underscore}\"] = ValueOrNull(object.#{name});\n"
      end
      template_content.gsub!('{{ properties_composing }}', composing)

      open(path, 'w') { |f|
        f.puts template_content
      }
    end

    def template_parameters
      generate_properties_parsing
      params = {
          class_name: class_name,
          mapping_tag: "{#{options[:name].downcase}}"
      }
      params
    end


  end

end
