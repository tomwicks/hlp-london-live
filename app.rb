require 'open-uri'
require 'i18n'
require 'sinatra'

class HelloLamppostWebsite < Sinatra::Base

  configure do
    I18n.load_path = Dir[File.join(settings.root, 'config', 'locales', '*.yml')]
    I18n.default_locale = :en
    I18n.backend.load_translations
  end

  helpers do

    def link_html_class(path)
      request.path_info.start_with?(path) ? 'current' : ''
    end

    def locale_path(path)
      return "/#{I18n.locale}#{path}"
    end

    def code_parser(code)

      code = code.to_s

      words = code.split(/\s+/)

      if words.length >= 2
        {
          object_type: (words[0..-2].join('_').downcase),
          object_code: words[-1].gsub("#", '')
        }
      else
        nil
      end

    end

  end

  before /.*/ do

    matches = request.path_info.match(/\A\/(fr|en)(.*)/)

    if matches

      I18n.locale       = matches[1]
      request.path_info = matches[2]
    else

      redirect to('/fr' + request.path_info)
    end
  end

  get '/questions/random' do
    cache_control :public, max_age: 0
    url = "http://hello-lamp-post-api.herokuapp.com/questions/random?location_id=3&locale=#{I18n.locale}"
    open(url).read
  end

  get '/' do
    @page_title = I18n.t(:home_title)
    erb :index
  end

  get '/how-to-play' do
    @page_title = I18n.t(:how_to_play_title)
    erb :how_to_play
  end

  get '/about' do
    @page_title = I18n.t(:about_title)
    erb :about
  end


end