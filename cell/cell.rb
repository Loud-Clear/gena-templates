
module Generate

  class Cell < BaseTemplate

    def sources_path
      "#{self.type_config['path']}/#{options[:scope]}/View/Cells"
    end

    def template_source_files
      files = []
      files << {
          'name' => 'Cell.h',
          'path' => 'Code/CellViews/Cell.h.liquid',
          'custom_name' => "{{ prefix }}{{ module_info.name }}Cell.h"
      }
      files << {
          'name' => 'Cell.m',
          'path' => 'Code/CellViews/Cell.m.liquid',
          'custom_name' => "{{ prefix }}{{ module_info.name }}Cell.m"
      }
      files << {
          'name' => 'CellItem.h',
          'path' => 'Code/CellItems/CellItem.h.liquid',
          'custom_name' => "{{ prefix }}{{ module_info.name }}CellItem.h"
      }
      files << {
          'name' => 'CellItem.m',
          'path' => 'Code/CellItems/CellItem.m.liquid',
          'custom_name' => "{{ prefix }}{{ module_info.name }}CellItem.m"
      }
      files
    end

    def template_test_files
      []
    end

    def template_parameters
      {}
    end

  end

end
