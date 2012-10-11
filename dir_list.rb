
module DirList
  def self.list_dir(root, path, show_hidden = false)
    results = []
    Dir.foreach("#{root + path}") do |x|
      full_path = root + path + '/' + x
      unless x == '.' || x == '..'
        unless !show_hidden && x[0] == '.'
          if File.directory?(full_path)
            results << { :abs_dir =>  "#{path}#{x}/", :rel_dir => "#{x}" }
          else
            ext = File.extname(full_path)
            results << { :file_ext => "#{ext[1..ext.length-1]}", :abs_file => "#{path}#{x}", :rel_file => "#{x}" }
          end
        end
      end
    end
    results
  end
end
