# frozen_string_literal: true

module PuppetDebugger
  module Support
    module Functions
      # returns a array of function files which is only required
      # when displaying the function map, puppet will load each function on demand
      # in the future we may want to utilize the puppet loaders to find these things
      def function_files
        search_dirs = lib_dirs.map do |lib_dir|
          [File.join(lib_dir, 'puppet', 'functions', '**', '*.rb'),
           File.join(lib_dir, 'functions', '**', '*.rb'),
           File.join(File.dirname(lib_dir), 'functions', '**', '*.pp'),
           File.join(lib_dir, 'puppet', 'parser', 'functions', '*.rb')]
        end
        # add puppet lib directories
        search_dirs << [File.join(puppet_lib_dir, 'puppet', 'functions', '**', '*.rb'),
                        File.join(puppet_lib_dir, 'puppet', 'parser', 'functions', '*.rb')]
        Dir.glob(search_dirs.flatten)
      end

      def data_type_files
        search_dirs = lib_dirs.map do |lib_dir|
          [File.join(lib_dir, 'puppet', 'functions', '**', '*.rb'),
           File.join(lib_dir, 'functions', '**', '*.rb'),
           File.join(lib_dir, 'puppet', 'parser', 'functions', '*.rb')]
        end
        # add puppet lib directories
        search_dirs << [File.join(puppet_lib_dir, 'puppet', 'functions', '**', '*.rb'),
                        File.join(puppet_lib_dir, 'puppet', 'parser', 'functions', '*.rb')]
        Dir.glob(search_dirs.flatten)
      end

      # returns either the module name or puppet version
      def mod_finder
        @mod_finder ||= Regexp.new('\/([\w\-\.]+)\/lib')
      end

      # returns a map of functions
      def function_map
        unless @functions
          do_initialize
          @functions = {}
          function_files.each do |file|
            obj = {}
            obj[:parent], obj[:name] = parent_name(file)
            # return the last matched in cases where rbenv might be involved
            @functions["#{obj[:parent]}::#{obj[:name]}"] = obj
          end
        end
        @functions
      end

      def parent_name(file)
        parent, name = [file.scan(mod_finder).flatten.last, File.basename(file, File.extname(file))] || begin
          File.read(file).scan(/function\s(\w+)::([:\w]+)/).captures
        end
      end

      # gather all the lib dirs
      def lib_dirs(module_dirs = modules_paths)
        dirs = module_dirs.map do |mod_dir|
          Dir["#{mod_dir}/*/lib"].entries
        end.flatten
        dirs + [puppet_repl_lib_dir]
      end

      # load all the lib dirs so puppet can find the functions
      # at this time, this function is not being used
      def load_lib_dirs(module_dirs = modules_paths)
        lib_dirs(module_dirs).each do |lib|
          $LOAD_PATH << lib
        end
      end
    end
  end
end
