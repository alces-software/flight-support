module Alces
  module Support
    ArticleNotFoundError = Class.new(RuntimeError)
    ArticleRenderError = Class.new(RuntimeError)
  end
end
