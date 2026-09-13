module WithTweets
   extend ActiveSupport::Concern

   def self.included base
      base.class_eval do
         attr_writer :tweet, :tweet_language, :tweet_alphabeth, :tweet_language_code, :tweet_alphabeth_code

         has_many :tweets, as: :describable, class_name: :Tweet, dependent: :delete_all
         has_many :default_tweets, -> { distinct }, through: :kind, source: :names, class_name: :Appellation
         has_many :all_tweets, ->(this) do
            where(describable_type: model.name, describable_id: this.id, kind: "Tweet")
              .or( Appellation.merge(this.kind.names)).order(:describable_type)
         end, primary_key: nil, class_name: :Description

         scope :by_tweet, -> tweet do
            this = table.table_alias || table.name
            as = "by_tweet_#{this}"

            join = "LEFT JOIN descriptions AS #{as}_tweets
                           ON #{as}_tweets.describable_id = #{this}.id
                          AND #{as}_tweets.describable_type = '#{model}'
                          AND #{as}_tweets.type IN ('Tweet')"

            joins(join).where("#{as}_tweets.text ~* ?", tweet)
         end

         scope :with_tweets, -> context do
            this = table.table_alias || table.name
            language_codes = context[:language] ? [context[:language]] : context[:text_languages]
            alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
            /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
            as = context[:as] || model.reflections[rela]&.name || rela
            selector = self.select_values.dup
            selector << "#{model.table_name}.*" if selector.empty?

            if self.model.attribute_names.include?("kind_code")
               kind_join =
                  "LEFT OUTER JOIN subjects AS #{as}_kinds
                                ON #{as}_kinds.kind_code = '#{model.name}Kind'
                               AND #{as}_kinds.key = #{as}.kind_code"
               kind_where =
                               "OR tweets.describable_id = #{as}_kinds.id
                               AND tweets.describable_type = 'Subject'
                               AND tweets.type IN ('Tweet')"
            end

            if language_codes.any?
               lang_wheres = [
                  "AND language_names.language_code IN ('#{language_codes.join("', '")}')",
                  "AND tweets.language_code IN ('#{language_codes.join("', '")}')"
               ]
            end

            if alphabeth_codes.any?
               alph_wheres = [
                  "AND alphabeth_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
                  "AND tweets.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"
               ]
            end

            selector << "COALESCE((WITH __tweets AS (
                            SELECT DISTINCT ON(tweets.id)
                                   tweets.id AS id,
                                   tweets.type AS type,
                                   tweets.text AS text,
                                   tweets.language_code AS language_code,
                                   tweets.alphabeth_code AS alphabeth_code,
                                   language_names.text AS language,
                                   alphabeth_names.text AS alphabeth
                              FROM descriptions AS tweets
                                   #{kind_join}
                   LEFT OUTER JOIN subjects AS languages
                                ON languages.key = tweets.language_code
                   LEFT OUTER JOIN descriptions AS language_names
                                ON language_names.describable_id = languages.id
                               AND language_names.describable_type = 'Subject'
                                   #{lang_wheres&.first}
                   LEFT OUTER JOIN subjects AS alphabeths
                                ON alphabeths.key = tweets.alphabeth_code
                   LEFT OUTER JOIN descriptions AS alphabeth_names
                                ON alphabeth_names.describable_id = alphabeths.id
                               AND alphabeth_names.describable_type = 'Subject'
                                   #{alph_wheres&.first}
                             WHERE tweets.id IS NOT NULL
                               AND (tweets.describable_id = #{as}.id
                               AND tweets.describable_type = '#{model}'
                               AND tweets.type IN ('Tweet')
                                   #{kind_where}) #{lang_wheres&.last} #{alph_wheres&.last}
                          GROUP BY tweets.id, tweets.describable_type, tweets.text,
                                   language_names.text, alphabeth_names.text)
                            SELECT jsonb_agg(__tweets)
                              FROM __tweets), '[]'::jsonb) AS _tweets"

            # binding.pry
            select(selector).group(:id)
         end

         scope :with_tweet, -> context do
            this = table.table_alias || table.name
            language_codes = context[:language] ? [context[:language]] : context[:text_languages]
            alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
            /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
            as = context[:as] || model.reflections[rela]&.name || rela
            selector = self.select_values.dup
            selector << "#{this}.*" if selector.empty?
            selector << "#{this}_tweets.text AS _tweet"

            join = "LEFT OUTER JOIN descriptions AS #{this}_tweets
                                 ON #{this}_tweets.describable_id = #{this}.id
                                AND #{this}_tweets.describable_type = '#{model}'
                                AND #{this}_tweets.type IN ('Tweet')
                                AND #{this}_tweets.language_code IN ('#{language_codes.join("', '")}')
                                AND #{this}_tweets.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"

            joins(join).select(selector.uniq).group('_tweet', "#{this}.id")
         end

         accepts_nested_attributes_for :tweets, reject_if: :all_blank, allow_destroy: true

         validates :tweets, associated: true

         before_validation :fill_in_tweet

         def tweet_language
            @tweet_language ||= tweets.last&.language.name
         end

         def tweet_alphabeth
            @tweet_alphabeth ||= tweets.last&.alphabeth.name
         end

         def tweet_language_code
            @tweet_language ||= tweets.last&.language_code
         end

         def tweet_alphabeth_code
            @tweet_alphabeth_code ||= tweets.last&.alphabeth_code
         end

         def fill_in_tweet
            if @tweet
               lc_pre = tweet_language_code || @language_code
               ac_pre = tweet_alphabeth_code || @alphabeth_code
               lc, ac = Languageble.la_for_string(@tweet, lc_pre, ac_pre)

               if tweet = tweets.where(language_code: lc, alphabeth_code: ac).first
                  tweet.update_attribute(:text, @tweet)
               else
                  tweets << Tweet.new(text: @tweet, language_code: lc, alphabeth_code: ac)
               end
            end
         end
      end
   end
end
