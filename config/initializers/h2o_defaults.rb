DEFAULT_TIMEZONE = 'Eastern Time (US & Canada)'
Formtastic::SemanticFormBuilder.escape_html_entities_in_hints_and_labels = false
#yes, this is probably too coarse.
WHITELISTED_TAGS = %w|a b br center del div em h1 h2 h3 h4 h5 h6 img li ol p strike strong ul blockquote|
WHITELISTED_ATTRIBUTES = %w|class src href height width target title|

require 'acts_as_taggable_on_extension'
ActsAsTaggableOn::Tag.send :include, ActsAsTaggableOnExtension 
