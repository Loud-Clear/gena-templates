
module Generate

  class Request < BaseTemplate

    def self.register_options(opts, options)
      opts.on('--method [METHOD]', [:GET, :POST, :PUT, :DELETE], 'request | Specify HTTP method for request') { |f| options[:method] = f }

    end

    def sources_path
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

    def template_source_files
      files = []
      files << {
          'name' => 'Request.h',
          'path' => 'Code/Request/request.h.liquid',
          'custom_name' => "{{ prefix }}RequestTo{{ module_info.name }}.h"
      }
      files << {
          'name' => 'Request.m',
          'path' => 'Code/Request/request.m.liquid',
          'custom_name' => "{{ prefix }}RequestTo{{ module_info.name }}.m"
      }
      if include_request_scheme?
        files << {
            'name' => 'Request.request.json',
            'path' => 'Code/Request/request.json.liquid',
            'custom_name' => "{{ prefix }}RequestTo{{ module_info.name }}.request.json",
            'is_resource' => true
        }
      end
      if include_response_scheme?
        files << {
            'name' => 'Request.response.json',
            'path' => 'Code/Request/request.json.liquid',
            'custom_name' => "{{ prefix }}RequestTo{{ module_info.name }}.response.json",
            'is_resource' => true
        }
      end

      files
    end

    def include_request_scheme?
      http_method == :POST || http_method == :PUT
    end

    def include_response_scheme?
      true
    end

    def template_test_files
      []
    end

    def template_parameters
      puts "method: #{self.http_method}"
      params = {
          http_method: http_method.to_s.downcase.capitalize_first
      }
      if include_request_scheme?
        params[:include_request_body] = true
      else
        params[:include_request_path] = true
      end
      params
    end

  end

end
