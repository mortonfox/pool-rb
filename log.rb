# frozen_string_literal: true

module PoolRB
  # Functions for writing messages to a HTML log file.
  class Log
    def initialize(prefix, path = nil, title = nil)
      path ||= './logs'
      fname = File.join path, "#{prefix}#{format '%08X', Time.now.to_i}.htm"
      @file = File.open fname, 'w'
      @file.sync = true

      @file.puts <<~HTML
        <html>
        <head>
        #{title ? "<title>#{title}</title>" : ''}
        </head>
        <body>
        #{title ? "<h1>#{title}</h1>" : ''}
        <p>
      HTML

      at_exit {
        @file.puts <<~HTML
          </p>
          </body>
          </html>
        HTML
        @file.close
        @file = nil
      }
    end

    def puts(msg)
      @file.puts "#{msg}<br />"
    end
  end
end

__END__
