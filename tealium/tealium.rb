module Generate

  class Tealium < BaseTemplate

    def sources_path
      source_path = `find ./#{config['sources_dir']} -type d -name "#{options[:name]}"`
      folder_name = source_path.split(File::SEPARATOR)[-2]
      "#{self.type_config['path']}/#{folder_name}"
    end

    def template_source_files
      files = [
          {'name' => 'Client.h', 'path' => 'Code/client.h.liquid', 'custom_name' => "{{ prefix }}{{ module_info.name }}TealiumClient.h"},
          {'name' => 'Client.m', 'path' => 'Code/client.m.liquid', 'custom_name' => "{{ prefix }}{{ module_info.name }}TealiumClient.m"}
      ]
      files
    end

  end

end