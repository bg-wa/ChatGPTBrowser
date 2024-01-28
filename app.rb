require 'gtk3'
require 'webkit2-gtk'
require 'fileutils'

class ChatGPTBrowser
  def initialize
    setup_base_directory
    setup_window
    setup_cookie_manager
    setup_webview
  end

  private

  def base_dir
    @base_dir ||= File.join(Dir.home, '.chat_gpt_browser')
  end

  def setup_base_directory
    FileUtils.mkdir_p(base_dir) unless File.directory?(base_dir)
    @web_context = WebKit2Gtk::WebContext.new(ephemeral: false)
  end

  def setup_window
    @window = Gtk::Window.new(Gtk::WindowType::TOPLEVEL)
    @window.set_title("ChatGPT Browser")
    @window.set_default_size(800, 600)
    @window.signal_connect('destroy') { Gtk.main_quit }
    setup_icon
  end

  def setup_icon
    icon_path = File.expand_path("assets/chat_gpt_icon.png", __dir__)
    @window.icon = GdkPixbuf::Pixbuf.new(file: icon_path) if File.exist?(icon_path)
  end

  def setup_cookie_manager
    cookie_manager = @web_context.cookie_manager
    cookie_manager.accept_policy = :ALWAYS
    cookies_path = File.join(base_dir, 'cookies')
    cookie_manager.set_persistent_storage(cookies_path, :TEXT)
  end

  def setup_webview
    webview = WebKit2Gtk::WebView.new(context: @web_context)
    webview.settings.enable_html5_local_storage = true
    webview.settings.enable_html5_database = true
    webview.load_uri("https://chat.openai.com/")
    @window.add(webview)
    @window.show_all
  end
end

# Run the application
app = ChatGPTBrowser.new
Gtk.main
