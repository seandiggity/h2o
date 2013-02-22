module AnnotatableExtensions
  def self.included(model)

    model.class_eval do
      #instance methods
      def deleteable?
        # Only allow deleting if there haven't been any collages created from this instance.
        self.collages.length == 0
      end
      def content_editable?
        # Only allow the content to be edited if there haven't been any collages created from this instance.
        self.collages.length == 0
      end

      # Note: This is split into two methods, to skip active record callbacks on migration
      def get_word_count
        content_to_prepare = self.content.gsub(/<br>/,'<br /> ')
        doc = Nokogiri::HTML.parse(content_to_prepare)
        doc.xpath('//*').each do |child|
          child.children.each do|c|
            if c.class == Nokogiri::XML::Text && ! c.content.blank?
              text_content = c.content.scan(/\S*\s*/).delete_if(&:empty?).map do |word|
                "<tt>" + word + '</tt> '
              end.join(' ')
    
              c.swap(text_content)
            end
          end
        end
        doc.xpath('//tt').size
      end

      def set_word_count
        self.update_attribute(:word_count, self.get_word_count)
      end
    end

    model.instance_eval do
      #class methods
      # Instances of this class are annotatable under the collage system.

      before_destroy :deleteable?

      def self.annotatable
        true
      end
    end
  end
end
