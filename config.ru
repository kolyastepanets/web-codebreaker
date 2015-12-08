require "./lib/racker"
use Rack::Session::Cookie, :key => 'rack.session',
                           :secret => 'change_me',
                           :old_secret => 'also_change_me'

use Rack::Static, :urls => ["/stylesheets"], :root => "public"

run Racker