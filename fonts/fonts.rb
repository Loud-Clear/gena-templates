
require 'ttfunk'
require 'plist'
require 'yaml'
require 'generamba'

module Generate

  class Fonts < BaseTemplate

    def get_font_paths
      font_paths = []
      Dir.glob("#{self.type_config['fonts_path']}/**/*").each do |f|
        begin
          if File.file?(f)
            TTFunk::File.open(f)
            font_paths << f
          end
        rescue
          puts "Skipping not font #{f}"
        end
      end
      return font_paths
    end

    def generate_plist(fonts)

      info_plist = Plist::parse_xml(self.config['plist_path'])

      info_plist["UIAppFonts"] = fonts

      open(self.config['plist_path'], 'w') { |f|
        f.puts info_plist.to_plist
      }
    end

    def load_project
      project_path = "#{self.config['project_name']}.xcodeproj"
      Generamba::XcodeprojHelper.obtain_project(project_path)
    end

    def add_fonts_to_project(fonts, project)
      target_name = self.config['project_target']
      dir = Pathname.new(self.type_config['fonts_path'])
      xcode_target = Generamba::XcodeprojHelper.obtain_target(target_name, project)
      group = Generamba::XcodeprojHelper.retrieve_group_or_create_if_needed(dir, dir, nil, project, true)


      #Clear group
      files_path = Generamba::XcodeprojHelper.files_path_from_group(group, project)
      files_path.each do |file_path|
        Generamba::XcodeprojHelper.remove_file_from_build_phases(file_path, [xcode_target.resources_build_phase])
      end
      group.clear

      #Add files to group
      fonts.each do |path|
        path = Pathname.new(self.type_config['fonts_path']).join(path)
        add_file_if_needed(xcode_target, group, path, true)
      end
    end

    def add_category_to_project(project)

      target_name = self.config['project_target']
      dir = Pathname.new(self.type_config['category_path'])

      xcode_target = Generamba::XcodeprojHelper.obtain_target(target_name, project)
      group = Generamba::XcodeprojHelper.retrieve_group_or_create_if_needed(dir, dir, nil, project, true)

      add_file_if_needed(xcode_target, group, category_header_path, false)
      add_file_if_needed(xcode_target, group, category_source_path, false)
    end

    def add_file_if_needed(target, group, file_path, is_resource)
      group.files.each do |file|
        if file.path == File.basename(file_path)
          return
        end
      end
      file = group.new_file(File.absolute_path(file_path))
      if is_resource
        target.add_resources([file])
      else
        target.add_file_references([file])
      end
    end

    def method_name_from_font(font_name)
      font_name = font_name.dup
      font_name.gsub!("\000", '')
      font_name.encode!('utf-8')
      font_name.gsub!("_", "")
      font_name.gsub!("-", "")
      font_name.gsub!(" ", "")
      font_name.strip!
      return font_name.lowercase_first
    end

    def generate_category(fonts)

      valid_names = []

      header = "// This is generated file\n// Do not modify\n\n@interface UIFont (CustomFonts)\n\n"
      implementation = "// This is generated file\n// Do not modify\n\n#import \"UIFont+CustomFonts.h\"\n\n@implementation UIFont (CustomFonts)\n\n"

      fonts.each do |f|
        file = TTFunk::File.open(f)

        if file.name.font_name
          font_name = file.name.font_name.last
          method_name = method_name_from_font(font_name)

          header += "+ (UIFont *)#{method_name}WithSize:(CGFloat)size;\n\n"

          implementation += "+ (UIFont *)#{method_name}WithSize:(CGFloat)size\n"
          implementation += "{\n    return [UIFont fontWithName:@\"#{file.name.font_name.last}\" size:size];\n}\n\n"

          puts "Registered #{file.name.font_name.last}"

          valid_names << File.basename(f)
        else
          puts "Font \"#{f}\" is invalid! Can't find font name. Skipping"
          if  File.extname(f) == ".ttc"
            puts "TTC fonts are not supported! Please unpack using http://transfonter.org/ttc-unpack"
          end
        end
      end

      header += "@end"
      implementation += "@end"

      header.gsub!("\000", '')
      implementation.gsub!("\000", '')

      open(category_header_path, 'w') { |f|
        f.puts header
      }
      open(category_source_path, 'w') { |f|
        f.puts implementation
      }

      return valid_names

    end

    def category_header_path
      "#{self.type_config['category_path']}/UIFont+CustomFonts.h"
    end

    def category_source_path
      "#{self.type_config['category_path']}/UIFont+CustomFonts.m"
    end

    def run
      fonts = get_font_paths
      valid_fonts = generate_category fonts
      generate_plist valid_fonts

      project = load_project
      add_fonts_to_project valid_fonts, project
      add_category_to_project project
      project.save

    end

    def self.generamba?
      false
    end
  end

end
