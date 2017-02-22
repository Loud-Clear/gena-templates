
module Generate


class Module < BaseTemplate

  def self.register_options(opts, options)
    opts.on('-s', '--scope [SUBFOLDER]', String, 'module | Specify subfolder (i.e. scope)') { |f| options[:scope] = f }
    opts.on('--story [STORY]', String, 'module | Specify story subfolder (only applied for \'module\' type)') { |f| options[:story] = f }

    opts.on('--view [VIEW]', String, 'module | Specify custom view name(only applied for \'module\' type)') { |f| options[:custom_view] = f }
    opts.on('--interactor [INTERACTOR]', String, 'module | Specify custom interactor name(only applied for \'module\' type)') { |f| options[:custom_interactor] = f }

    opts.on('--only-view', 'module | Generate reusable View in right place') {  options[:only_view] = true }
    opts.on('--only-interactor', 'module | Generate reusable Interactor in right place') {  options[:only_interactor] = true }
  end

  def sources_path
    if options[:story]
      result = "#{self.type_config['stories_path']}/#{options[:story]}"
    elsif options[:only_view]
      result = self.type_config['common_views_path']
    elsif options[:only_interactor]
      result = self.type_config['common_interactors_path']
    else
      result = self.type_config['modules_path']
    end
    if options[:scope]
      result = "#{result}/#{options[:scope]}"
    end
    result
  end

  def template_source_files
    files = []

    view_subpath = options[:only_view] ? '' : 'View/'
    interactor_subpath = options[:only_interactor] ? '' : 'Interactor/'

    if include_view?
      files << {'name' => "#{view_subpath}ViewInputOutput.h", 'path' => 'Code/View/view_input_output.h.liquid'}
      files << {'name' => "#{view_subpath}ViewController.h", 'path' => 'Code/View/viewcontroller.h.liquid'}
      files << {'name' => "#{view_subpath}ViewController.m", 'path' => 'Code/View/viewcontroller.m.liquid'}
    end

    if include_presenter?
      files << {'name' => 'Assembly/Assembly.h', 'path' => 'Code/Assembly/assembly.h.liquid'}
      files << {'name' => 'Assembly/Assembly.m', 'path' => 'Code/Assembly/assembly.m.liquid'}
      files << {'name' => 'Presenter/ModuleInput.h', 'path' => 'Code/Presenter/module_input.h.liquid'}
      files << {'name' => 'Presenter/Presenter.h', 'path' => 'Code/Presenter/presenter.h.liquid'}
      files << {'name' => 'Presenter/Presenter.m', 'path' => 'Code/Presenter/presenter.m.liquid'}
      files << {'name' => 'Router/RouterInput.h', 'path' => 'Code/Router/router_input.h.liquid'}
      files << {'name' => 'Router/Router.h', 'path' => 'Code/Router/router.h.liquid'}
      files << {'name' => 'Router/Router.m', 'path' => 'Code/Router/router.m.liquid'}
    end

    if include_interactor?
      files << {'name' => "#{interactor_subpath}InteractorInputOutput.h", 'path' => 'Code/Interactor/interactor_input_output.h.liquid'}
      files << {'name' => "#{interactor_subpath}Interactor.h", 'path' => 'Code/Interactor/interactor.h.liquid'}
      files << {'name' => "#{interactor_subpath}Interactor.m", 'path' => 'Code/Interactor/interactor.m.liquid'}
    end

    files
  end

  def template_test_files
    files = []

    view_subpath = options[:only_view] ? '' : 'View/'
    interactor_subpath = options[:only_interactor] ? '' : 'Interactor/'

    if include_view?
      files << {'name' => "#{view_subpath}/ViewControllerTests.m", 'path' => 'Tests/View/view_tests.m.liquid'}
    end

    if include_presenter?
      files << {'name' => 'Assembly/AssemblyTests.m', 'path' => 'Tests/Assembly/assembly_tests.m.liquid'}
      files << {'name' => 'Assembly/Assembly_Testable.h', 'path' => 'Tests/Assembly/assembly_testable.h.liquid'}
      files << {'name' => 'Router/RouterTests.m', 'path' => 'Tests/Router/router_tests.m.liquid'}
      files << {'name' => 'Presenter/PresenterTests.m', 'path' => 'Tests/Presenter/presenter_tests.m.liquid'}
    end

    if include_interactor?
      files << {'name' => "#{interactor_subpath}/InteractorTests.m", 'path' => 'Tests/Interactor/interactor_tests.m.liquid'}
    end

    files
  end

  def include_view?
    !options[:custom_view] && !options[:only_interactor]
  end

  def include_interactor?
    !options[:custom_interactor] && !options[:only_view]
  end

  def include_presenter?
    !options[:only_view] && !options[:only_interactor]
  end

  def template_parameters
    params = {
        view: options[:custom_view] || options[:name],
        interactor: options[:custom_interactor] || options[:name]
    }
    params
  end

end

end
