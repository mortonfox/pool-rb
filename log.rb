module PoolRB

  class Log

    def initialize prefix, path = nil, title = nil
      path ||= './logs'
      fname = File.join path, "#{prefix}#{"%08X" % Time.now.to_i}.htm"
      @file = File.open fname, 'w'
      @file.sync = true

      @file.puts <<-EOM
<html>
<head>
#{title ? "<title>#{title}</title>" : ''}
</head>
<body>
#{title ? "<h1>#{title}</h1>" : ''}
<p>
      EOM

      at_exit {
        @file.puts <<-EOM
</p>
</body>
</html>
        EOM
        @file.close
        @file = nil
      }
    end

    def puts msg
      @file.puts "#{msg}<br />"
    end
  end
end
