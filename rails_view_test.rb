require RAILS_ROOT + '/test/test_helper'

class RailsViewTest < ActionView::TestCase
  class_inheritable_accessor :controller_class
  @@controller_class = nil

  class << self
    # Sets the controller that is tested by this test suite.
    def tested_controller(controller_class)
      @@controller_class = controller_class
    end

    def controller_class
      @@controller_class || find_controller_class
    end

    private

    def find_controller_class
      (__FILE__.sub(/ViewTest$/, '') + 'Controller').constantize
    rescue NameError
      raise "Unable to determine the controller"
    end
  end

  def setup
    @controller = self.class.controller_class.new
    @controller.request = @request = ActionController::TestRequest.new
    @controller.response = @response = ActionController::TestResponse.new

    @controller.session = ActionController::TestSession.new
    @controller.params = {}
    @controller.send(:initialize_current_url)

    @assigns = {}
    @view = ActionView::Base.new(ActionController::Base.view_paths, @assigns)
    @view.expects(:controller).at_least(0).returns(@controller)
    @view.expects(:request).at_least(0).returns(@request)

    @controller.response.template = @view
    @controller.expects(:controller).at_least(0).returns(@controller)
    @controller.expects(:request).at_least(0).returns(@request)
    @controller.expects(:protect_against_forgery?).at_least(0).returns(false)
    ActionView::Base.send(:include, @controller.class.master_helper_module)
  end

  # Similar to +ActionController::Base#render+, but does some preparation before
  # calling render.
  def render_action(attrs)
    controller_name = attrs[:controller] || self.controller_class.controller_name
    action_name = attrs[:action]
    @controller.action_name = action_name
    prepare_data
    self.instance_variables.collect{|v| @assigns[v[1..-1]] = self.instance_eval("#{v}")}
    render_opts = {:file => "#{controller_name}/#{action_name}"}
    render_opts[:layout] = "layouts/" + (attrs[:layout] || 'application')

    view_html = @view.render(render_opts)
    set_response_text(view_html)
  end

  # Similar to +setup+, but sets up just some commong data to be used by the
  # view.
  def prepare_data
    # This method is just a stub.
  end
end
