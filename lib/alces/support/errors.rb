module Alces
  module Support
    ArticleNotFoundError = Class.new(RuntimeError)
    ArticleRenderError = Class.new(RuntimeError)
    NotAuthenticatedError = Class.new(RuntimeError)
    TopicFetchError = Class.new(RuntimeError)
  end
end
