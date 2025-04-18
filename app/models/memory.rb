# council[string]       - соборы для памяти
# short_name[string]    - краткое имя
# quantity[string]      - количество
#
class Memory < ApplicationRecord
   extend TotalSize
   extend DefaultKey
   extend Informatible
   include DistinctBy
   include WithTitles
   include WithDescriptions
   include WithTweets
   include WithNotes
   include WithLinks
   include ByToken

   has_one :slug, as: :sluggable, dependent: :destroy
   has_many :memory_names, dependent: :destroy
   has_many :short_names, dependent: :destroy
   has_many :nomina, through: :memory_names
   has_many :names, through: :nomina
   has_many :paterics, as: :info, dependent: :destroy, class_name: :PatericLink
   has_many :events, dependent: :destroy
   has_many :memos, through: :events
   has_many :service_scripta, through: :services
   has_many :scripta, through: :service_scripta
   has_many :calendaries, -> { distinct.reorder('id') }, through: :memos
   has_many :roundels, -> { where(roundels: { roundelable_type: "Memory" }) }, foreign_key: :roundelable_id, dependent: :destroy
   has_many :attitudes, as: :imageable, class_name: :ImageAttitude
   has_many :pictures, through: :attitudes
   has_many :notes, as: :describable, dependent: :destroy, class_name: :Note
   has_many :orders, -> { distinct.reorder('id') }, through: :memos, source: :orders
   has_many :slugs, -> { distinct.reorder('id') }, through: :orders, source: :slug
   has_many :memory_binds
   has_many :bond_memories, through: :memory_binds, foreign_key: :bond_to_id, class_name: :Memory
   has_many :coverings
   has_many :places, through: :coverings

   default_scope { order( base_year: :asc, id: :asc ) }

   scope :icons, -> { joins( :slugs ).where( slugs: { text: :обр } ) }

   scope :by_short_name, -> name { joins(:short_names).where(short_names: { text: name }) }
   scope :by_slug, -> slug do
      this = table.table_alias || table.name
      join = "JOIN slugs AS #{this}_slugs
           ON #{this}.id = #{this}_slugs.sluggable_id
          AND #{this}_slugs.sluggable_type = 'Memory'"

      selector = "#{this}_slugs.text = ?", slug

      joins(join).where(selector).order(:id).distinct
   end

   scope :in_calendaries, -> calendaries_in do
      calendaries = calendaries_in.is_a?(String) && calendaries_in.split(',') || calendaries_in
      left_outer_joins( :memos ).merge( Memo.in_calendaries( calendaries )).distinct
   end

   scope :by_date, -> (date, julian = false) do
      left_outer_joins(:memos).merge(Memo.by_date(date, julian)).distinct
   end

   scope :by_token, -> text do
      left_outer_joins(:short_names, :names, :descriptions, :notes, :tweets, :slug).
         where("unaccent(short_names.text) ~* ?", "\\m#{text}.*").or(
         where("unaccent(descriptions.text) ~* unaccent(?)", "\\m#{text}.*").or(
         where("unaccent(tweets_memories.text) ~* unaccent(?)", "\\m#{text}.*").or(
         where("unaccent(notes_memories.text) ~* unaccent(?)", "\\m#{text}.*").or(merge(
         Nomen.joins(:name).where("unaccent(names.text) ~* unaccent(?)", "\\m#{text}.*").by_root)).or(where(slugs: {text: text.split(",")}))))).distinct
   end

   # by title with short_name
   scope :by_title, -> text do
      this = table.table_alias || table.name
      join = "LEFT OUTER JOIN descriptions AS #{this}_titles
                           ON #{this}.id = #{this}_titles.describable_id
                          AND #{this}_titles.describable_type = 'Memory'
              LEFT OUTER JOIN short_names AS #{this}_short_names
                           ON #{this}.id = #{this}_short_names.memory_id"

      selector = "unaccent(#{this}_titles.text) ~* unaccent(?)
             OR #{this}_short_names.text ~* ?", "\\m#{text}.*", "\\m#{text}.*"

      joins(join).where(selector).distinct
   end

   scope :by_id, ->(id) { where(id: id.to_s.strip) }

   # by unique universal numbering object: by id, by slug, by short_name
   scope :by_uno, ->(uno) do
      case uno
      when /^\s*$/
         none
      when /^\s*\d+\s*$/
         by_id(uno)
      when /^[а-яё0-9]+$/
         by_slug(uno)
      else
         by_short_name(uno)
      end
   end

   # required for short list
   scope :with_key, -> _ do
      selector = [ 'memories.id AS _key' ]

      select(selector).group('_key').reorder("_key")
   end

   scope :with_value, -> context do
      #TODO add search over names
      selector = [ 'short_names.text AS _value' ]

      joins(:short_names).select(selector).group('_value').reorder("_value")
   end

   scope :with_short_name, -> context do
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || rela
      ast = as.to_s.tableize
      asm = as.to_s.singularize.camelize
      this = table.table_alias || table.name
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "#{this}_#{ast}.text AS _#{ast.singularize}"

      join = "          JOIN #{ast} AS #{this}_#{ast}
                          ON #{this}_#{ast}.memory_id = #{this}.id
                         AND #{this}_#{ast}.language_code IN ('#{language_codes.join("', '")}')
                         AND #{this}_#{ast}.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"
      group = [:id, "#{this}_#{ast}.text"]

      joins(join).select(selector).group(*group)
   end

   scope :with_short_names, -> context do
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || rela
      ast = as.to_s.tableize
      asm = as.to_s.singularize.camelize
      this = table.table_alias || table.name
      language_codes = [context[:text_languages]].flatten.compact
      alphabeth_codes = [context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)].flatten

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?

      if language_codes.any?
         lang_wheres = [
            "AND language_names.language_code IN ('#{language_codes.join("', '")}')",
            "AND #{this}_#{ast}.language_code IN ('#{language_codes.join("', '")}')"
         ]
      end

      if alphabeth_codes.any?
         alph_wheres = [
            "AND alphabeth_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
            "AND #{this}_#{ast}.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"
         ]
      end

      selector << "COALESCE((with __#{ast} AS (
                      SELECT DISTINCT ON(#{this}_#{ast}.id)
                             #{this}_#{ast}.id AS id,
                             #{this}_#{ast}.text AS text,
                             #{this}_#{ast}.language_code AS language_code,
                             #{this}_#{ast}.alphabeth_code AS alphabeth_code,
                             language_names.text AS language,
                             alphabeth_names.text AS alphabeth
                        FROM #{ast} AS #{this}_#{ast}
             LEFT OUTER JOIN subjects AS languages
                          ON languages.key = #{this}_#{ast}.language_code
             LEFT OUTER JOIN descriptions AS language_names
                          ON language_names.describable_id = languages.id
                         AND language_names.describable_type = 'Subject'
                             #{lang_wheres&.first}
             LEFT OUTER JOIN subjects AS alphabeths
                          ON alphabeths.key = #{this}_#{ast}.alphabeth_code
             LEFT OUTER JOIN descriptions AS alphabeth_names
                          ON alphabeth_names.describable_id = alphabeths.id
                         AND alphabeth_names.describable_type = 'Subject'
                             #{alph_wheres&.first}
                       WHERE #{this}_#{ast}.memory_id = #{this}.id
                             #{lang_wheres&.last} #{alph_wheres&.last}
                    GROUP BY #{this}_#{ast}.id, language_names.text, alphabeth_names.text)
                      SELECT jsonb_agg(__#{ast})
                        FROM __#{ast}), '[]'::jsonb) AS _#{ast}"

      select(selector).group(:id)
   end

   scope :with_names, -> (context) do
      language_codes = [context[:text_languages]].flatten
      alphabeth_codes = [context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)].flatten
=begin
with recursive t(level,path,id,name_id,bind_kind_name,bond_to_id,root_id,name_alphabeth_code,name_language_code,name_text,state_code,mode,feasible) as (
        with recursive tt(level,path,id,name_id,bind_kind_name,bond_to_id,root_id,name_alphabeth_code,name_language_code,name_text,state_code,mode,feasible) as (SELECT 0,nm.text,n.id,n.name_id,n.bind_kind_name,n.bond_to_id,n.root_id,nm.alphabeth_code,nm.language_code,nm.text,mn.state_code,mn.mode,mn.feasible FROM nomina n JOIN names nm ON nm.id = n.name_id JOIN memory_names mn ON mn.nomen_id = n.id WHERE  mn.memory_id = 2989 UNION SELECT level + 1, path || ' > ' || nm.text, n.id,n.name_id,n.bind_kind_name,n.bond_to_id,n.root_id,nm.alphabeth_code,nm.language_code,nm.text,tt.state_code,tt.mode,tt.feasible FROM nomina n JOIN tt ON n.root_id = tt.root_id AND  tt.bond_to_id = n.name_id JOIN names nm ON nm.id = n.name_id JOIN names nm_t ON nm_t.id = tt.name_id AND nm_t.language_code <> nm.language_code LEFT OUTER JOIN memory_names mn ON n.root_id = mn.nomen_id AND mn.memory_id = 2989 ) select * from tt
    UNION
        SELECT DISTINCT
            level + 1,
            path || ' > ' || nm.text,
            n.id,n.name_id,n.bind_kind_name,n.bond_to_id,n.root_id,nm.alphabeth_code,nm.language_code,nm.text,t.state_code,t.mode,t.feasible
        FROM
            nomina n JOIN t
                ON n.bond_to_id = t.name_id AND n.root_id = t.root_id JOIN names nm ON nm.id = n.name_id JOIN names nm_t ON nm_t.id = t.name_id AND nm_t.language_code <> nm.language_code LEFT OUTER JOIN memory_names mn ON n.root_id = mn.nomen_id AND mn.memory_id = 2989
) select * from t  WHERE name_language_code IN ('ру')
=end

      selector = "COALESCE((
              WITH RECURSIVE __names(level,path,id,name_id,name_bind_kind_name,bond_to_id,root_id,name_alphabeth_code,name_language_code,name_text,state_code,mode,feasible) AS (
              WITH RECURSIVE tt(level,path,id,name_id,bind_kind_name,bond_to_id,root_id,name_alphabeth_code,name_language_code,name_text,state_code,mode,feasible) AS (
                      SELECT 0,
                             nm.text,
                             n.id,
                             n.name_id,
                             n.bind_kind_name,
                             n.bond_to_id,
                             n.root_id,
                             nm.alphabeth_code,
                             nm.language_code,
                             nm.text,
                             mn.state_code,
                             mn.mode,
                             mn.feasible
                        FROM nomina n
                        JOIN names nm
                          ON nm.id = n.name_id
                        JOIN memory_names mn
                          ON mn.nomen_id = n.id
                         AND mn.memory_id = memories.id
                       UNION

                      SELECT 0,
                             nm.text,
                             n.id,
                             n.name_id,
                             n.bind_kind_name,
                             n.bond_to_id,
                             n.root_id,
                             nm.alphabeth_code,
                             nm.language_code,
                             nm.text,
                             tt.state_code,
                             tt.mode,
                             tt.feasible
                        FROM nomina n
                        JOIN tt
                          ON n.root_id = tt.root_id AND tt.bond_to_id = n.name_id
                        JOIN names nm
                          ON nm.id = n.name_id
                        JOIN names nm_t
                          ON nm_t.id = tt.name_id
                         AND nm_t.language_code <> nm.language_code
             LEFT OUTER JOIN memory_names mn
                          ON n.root_id = mn.nomen_id
                         AND mn.memory_id = memories.id)
                      SELECT *
                        FROM tt

                       UNION
                      SELECT level + 1,
                             path || ' > ' || nm.text,
                             n.id,
                             n.name_id,
                             n.bind_kind_name,
                             n.bond_to_id,
                             n.root_id,
                             nm.alphabeth_code,
                             nm.language_code,
                             nm.text,
                             t.state_code,
                             t.mode,
                             t.feasible
                        FROM nomina n
                        JOIN __names t
                          ON n.bond_to_id = t.name_id
                         AND n.root_id = t.root_id
                        JOIN names nm
                          ON nm.id = n.name_id
                        JOIN names nm_t
                          ON nm_t.id = t.name_id
                         AND nm_t.language_code <> nm.language_code
             LEFT OUTER JOIN memory_names mn
                          ON n.root_id = mn.nomen_id
                         AND mn.memory_id = memories.id)
                      SELECT jsonb_agg(__names)
                        FROM __names
                       WHERE __names.name_language_code IN ('#{language_codes.join("', '")}')
                         AND __names.name_alphabeth_code IN ('#{alphabeth_codes.join("', '")}')), '[]'::jsonb) AS _names"

      select(selector).group(:id)
   end

   scope :with_scripta, -> (context) do
      as = table.table_alias || table.name
      language_codes = [context[:service_languages]].flatten
      alphabeth_codes = context[:codes] || Languageble.alphabeth_list_for(language_codes).flatten
      calendaries_join =
         if context[:calendary_slugs]
             "JOIN calendaries AS #{as}_calendaries
                ON #{as}_calendaries.id = #{as}_memoes.calendary_id
              JOIN slugs AS #{as}_calendary_slugs
                ON #{as}_calendary_slugs.id = #{as}_calendaries.id
               AND #{as}_calendary_slugs.sluggable_type = 'Calendary'
               AND #{as}_calendary_slugs.text IN ('#{context[:calendary_slugs].join("','")}')"
         end

      selector = self.select_values.dup
      selector << "#{as}.*" if selector.empty?
      selector << "COALESCE((WITH
                                    __texted_audios AS (
                             SELECT #{as}_scripta.id AS id,
                                    #{as}_audios.uid AS audio_uid,
                                    #{as}_audios.url AS audio_url,
                                    #{as}_audios.kind AS audio_kind
                               FROM scripta AS #{as}_scripta
                    LEFT OUTER JOIN scriptum_scribables AS #{as}_scriptum_scribables
                                 ON #{as}_scripta.id = #{as}_scriptum_scribables.scriptum_id
                                AND 'source' = #{as}_scriptum_scribables.kind
                    LEFT OUTER JOIN audios AS #{as}_audios
                                 ON #{as}_audios.id = #{as}_scriptum_scribables.scribable_id
                                AND 'Audio' = #{as}_scriptum_scribables.scribable_type),
                                    __scripta AS (
                             SELECT DISTINCT ON (#{as}_scripta.id)
                                    #{as}_scripta.id AS id,
                                    #{as}_scripta.text AS text,
                                    #{as}_scripta.tone AS tone,
                                    #{as}_scripta.type AS type,
                                    #{as}_scripta.language_code AS language_code,
                                    #{as}_scripta.alphabeth_code AS alphabeth_code,
                                    #{as}_scripta.prosomeion_title AS prosomeion_title,
                                    #{as}_scripta.title AS title,
                                    #{as}_scripta.ref_title AS ref_title,
                                    __texted_audios.audio_uid AS audio_uid,
                                    __texted_audios.audio_url AS audio_url,
                                    __texted_audios.audio_kind AS audio_kind
                               FROM scripta AS #{as}_scripta
                               JOIN events
                                 ON memories.id = events.memory_id
                                AND events.kind_code IN ('#{Event::NOTICE.join("','")}')
                               JOIN memoes AS #{as}_memoes
                                 ON events.id = #{as}_memoes.event_id
                               JOIN memo_scripta
                                 ON memo_scripta.memo_id = #{as}_memoes.id
                                    #{calendaries_join}
                    LEFT OUTER JOIN __texted_audios
                                 ON __texted_audios.id = #{as}_scripta.id
                              WHERE #{as}_scripta.id = memo_scripta.scriptum_id
                                AND #{as}_scripta.language_code IN ('#{language_codes.join("', '")}')
                                AND #{as}_scripta.alphabeth_code IN ('#{alphabeth_codes.join("', '")}'))
                             SELECT jsonb_agg(__scripta)
                               FROM __scripta), '[]'::jsonb) AS _scripta"

      # binding.pry # find_by_slug(@slug.text)
      select(selector).group(:id)
   end

   scope :with_memory_binds, -> context do
      this = table.table_alias || table.name
      language_codes = [context[:text_languages]].flatten.compact
      alphabeth_codes = context[:codes] || Languageble.alphabeth_list_for(language_codes)

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "COALESCE((WITH __memory_binds AS (
                       SELECT #{this}_memory_binds.id AS id,
                              #{this}_memory_binds.bond_to_id AS bond_to_id,
                              #{this}_memory_binds.kind AS kind,
                              #{this}_bond_short_names.text AS bond_to_name
                         FROM memory_binds AS #{this}_memory_binds
                         JOIN memories AS #{this}_bond_memories
                           ON #{this}_bond_memories.id = #{this}_memory_binds.bond_to_id
              LEFT OUTER JOIN short_names AS #{this}_bond_short_names
                           ON #{this}_bond_memories.id = #{this}_bond_short_names.memory_id
                          AND #{this}_bond_short_names.language_code IN ('#{language_codes.join("', '")}')
                          AND #{this}_bond_short_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
                        WHERE #{this}.id = #{this}_memory_binds.memory_id)
                       SELECT jsonb_agg(__memory_binds)
                         FROM __memory_binds), '[]'::jsonb) AS _memory_binds"

      select(selector).group(:id)
   end

   scope :with_covering_names, -> context do
      as = table.table_alias || table.name
      language_codes = [context[:text_languages]].flatten

      selector = self.select_values.dup
      selector << "#{as}.*" if selector.empty?
      selector << "COALESCE((WITH __coverings AS (
                       SELECT #{as}_coverings.id AS id,
                              #{as}_coverings.add_date AS add_date,
                              #{as}_coverings.place_id AS place_id,
                              #{as}_place_descriptions.text || ' (' || #{as}_place_descriptions.language_code || '_' || #{as}_place_descriptions.alphabeth_code || ')' AS place_name
                         FROM coverings AS #{as}_coverings
                         JOIN memories AS #{as}_places
                           ON #{as}_places.id = #{as}_coverings.place_id
                          AND #{as}_places.type = 'Place'
              LEFT OUTER JOIN descriptions AS #{as}_place_descriptions
                           ON #{as}_place_descriptions.describable_id = #{as}_places.id
                          AND #{as}_place_descriptions.describable_type = 'Place'
                          AND #{as}_place_descriptions.language_code IN ('#{language_codes.join("', '")}')
                        WHERE #{as}.id = #{as}_coverings.memory_id)
                       SELECT jsonb_agg(__coverings)
                         FROM __coverings), '[]'::jsonb) AS _coverings"

      select(selector).group(:id)
   end

   scope :with_coverings, -> context do
      as = table.table_alias || table.name
      language_codes = [context[:text_languages]].flatten

      selector = self.select_values.dup
      selector << "#{as}.*" if selector.empty?
      selector << "COALESCE((WITH __coverings AS (
                       SELECT #{as}_coverings.id AS id,
                              #{as}_coverings.add_date AS add_date,
                              #{as}_coverings.place_id AS place_id,
                              #{as}_place_descriptions.text AS name
                         FROM coverings AS #{as}_coverings
                         JOIN memories AS #{as}_places
                           ON #{as}_places.id = #{as}_coverings.place_id
                          AND #{as}_places.type = 'Place'
              LEFT OUTER JOIN descriptions AS #{as}_place_descriptions
                           ON #{as}_place_descriptions.describable_id = #{as}_places.id
                          AND #{as}_place_descriptions.describable_type = 'Place'
                          AND #{as}_place_descriptions.language_code IN ('#{language_codes.join("', '")}')
                        WHERE #{as}.id = #{as}_coverings.memory_id)
                       SELECT jsonb_agg(__coverings)
                         FROM __coverings), '[]'::jsonb) AS _coverings"

      select(selector).group(:id)
   end

   # with memoes and children via memoes
   scope :with_memoed, -> context do
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || rela
      this = table.table_alias || table.name
      language_codes = [context[:text_languages] || context[:language]].flatten
      alphabeth_codes = context[:text_alphabeths] || Languageble.alphabeth_list_for( language_codes ).flatten
      cslugs_rule = context[:calendary_slugs] ? "AND #{this}_calendary_slugs.text IN ('#{context[:calendary_slugs].join("','")}')" : ""

      selector = "#{this}.id,
                  #{this}_slugs.text AS _slug,
                  #{this}.base_year,
                  #{this}_roundels.url AS _roundel_url,
                  #{this}_order_tweets.text AS _order_tweet,
                  #{this}_order_short_names.text AS _order_short_name,
                  #{this}_titles.text AS _title,
                  #{this}_events.happened_at AS _happened_at,
                  #{this}_notes.text AS _note,
                  json_agg(distinct #{this}_calendary_slugs.text) AS _calendary_slugs"

      join =            "JOIN events AS #{this}_events
                           ON #{this}.id = #{this}_events.memory_id
                         JOIN slugs AS #{this}_slugs
                           ON #{this}_slugs.sluggable_id = #{this}.id
                          AND #{this}_slugs.sluggable_type = 'Memory'
                         JOIN memoes AS #{this}_memoes
                           ON #{this}_memoes.event_id = #{this}_events.id
                         JOIN calendaries AS #{this}_calendaries
                           ON #{this}_calendaries.id = #{this}_memoes.calendary_id
                         JOIN slugs AS #{this}_calendary_slugs
                           ON #{this}_calendary_slugs.sluggable_id = #{this}_calendaries.id
                          AND #{this}_calendary_slugs.sluggable_type = 'Calendary'
                              #{cslugs_rule}
                         JOIN memoes AS #{this}_memo_hosts
                           ON #{this}_memoes.bond_to_id = #{this}_memo_hosts.id
                          AND #{this}_memoes.bind_kind_code = 'соборный'
                         JOIN events AS #{this}_host_events
                           ON #{this}_memo_hosts.event_id = #{this}_host_events.id
                          AND #{this}_host_events.memory_id = #{context[:uno]}
              LEFT OUTER JOIN descriptions AS #{this}_titles
                           ON #{this}_titles.describable_id = #{this}_memoes.id
                          AND #{this}_titles.describable_type = 'Memo'
                          AND #{this}_titles.type = 'Title'
                          AND #{this}_titles.language_code IN ('#{language_codes.join("', '")}')
                          AND #{this}_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
              LEFT OUTER JOIN memo_orders AS #{this}_memo_orders
                           ON #{this}_memo_orders.memo_id = #{this}_memoes.id
              LEFT OUTER JOIN memories AS #{this}_orders
                           ON #{this}_orders.id = #{this}_memo_orders.order_id
                          AND #{this}_orders.type = 'Order'
              LEFT OUTER JOIN short_names AS #{this}_order_short_names
                           ON #{this}_orders.id = #{this}_order_short_names.memory_id
                          AND #{this}_order_short_names.language_code IN ('#{language_codes.join("', '")}')
                          AND #{this}_order_short_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
              LEFT OUTER JOIN descriptions AS #{this}_order_tweets
                           ON #{this}_order_tweets.describable_id = #{this}_orders.id
                          AND #{this}_order_tweets.describable_type = 'Memory'
                          AND #{this}_order_tweets.type = 'Tweet'
                          AND #{this}_order_tweets.language_code IN ('#{language_codes.join("', '")}')
                          AND #{this}_order_tweets.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
              LEFT OUTER JOIN LATERAL (
                       SELECT #{this}_roundels.url AS url,
                              #{this}_roundels.roundelable_id AS id,
                              #{this}_roundels.roundelable_type AS type
                         FROM roundels AS #{this}_roundels
                        WHERE #{this}_roundels.url IS NOT NULL
                          AND (#{this}_events.memory_id = #{this}_roundels.roundelable_id
                          AND 'Memory' = #{this}_roundels.roundelable_type
                           OR #{this}_events.id = #{this}_roundels.roundelable_id
                          AND 'Event' = #{this}_roundels.roundelable_type)
                     ORDER BY random()
                        LIMIT 1) AS #{this}_roundels
                           ON #{this}_roundels.type IN ('Memory', 'Event')
              LEFT OUTER JOIN descriptions AS #{this}_notes
                           ON #{this}_notes.describable_id = #{this}_memoes.id
                          AND #{this}_notes.describable_type = 'Memo'
                          AND #{this}_notes.type = 'Note'
                          AND #{this}_notes.language_code IN ('#{language_codes.join("', '")}')
                          AND #{this}_notes.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"

      group_by = [
         :id,
         :base_year,
         "#{this}_slugs.text",
         "#{this}_roundels.url",
         "#{this}_order_tweets.text",
         "#{this}_order_short_names.text",
         "#{this}_titles.text",
         "#{this}_events.happened_at",
         "#{this}_notes.text",
         "#{this}_calendary_slugs.text"
      ]

      joins(join).select(selector).reorder("#{this}_slugs.text").group(*group_by).distinct_by("#{this}_slugs.text")
   end

   # with memoes and children via memoes
   scope :with_memoes, -> context do
      this = table.table_alias || table.name
      language_codes = [context[:text_languages]].flatten
      alphabeth_codes = context[:text_alphabeths] || Languageble.alphabeth_list_for( language_codes ).flatten
      cslugs_rule = context[:calendary_slugs] ? "AND calendary_slugs.text IN ('#{context[:calendary_slugs].join("','")}')" : ""
      cslugs_rule2 = context[:calendary_slugs] ? "AND #{this}_calendary_slugs.text IN ('#{context[:calendary_slugs].join("','")}')" : ""

      selector = "COALESCE((WITH __memoes AS (
                       SELECT DISTINCT ON(memoes.id)
                              memoes.id AS id,
                              memoes.year_date AS year_date,
                              events.kind_code AS kind_code,
                              jsonb_object_agg(DISTINCT COALESCE(memo_slugs.text, 'Null'),
                                                        order_titles_memoes.text) AS orders,
               COALESCE((WITH ___children AS (
                       SELECT DISTINCT ON(children_slugs.text)
                              children_slugs.text AS slug
                         FROM slugs AS children_slugs
                         JOIN events AS #{this}_children_events
                           ON children_slugs.sluggable_id = #{this}_children_events.memory_id
                          AND children_slugs.sluggable_type = 'Memory'
                         JOIN memoes AS children
                           ON children.event_id = #{this}_children_events.id
                          AND children.bind_kind_code = 'соборный'
                         JOIN memoes AS hosts
                           ON children.bond_to_id = hosts.id
                         JOIN events AS #{this}_host_events
                           ON hosts.event_id = #{this}_host_events.id
                          AND #{this}_host_events.memory_id = #{this}.id)
                       SELECT COUNT(___children.slug)
                         FROM ___children), 0) AS children_total,
               COALESCE((WITH __children AS (
                       SELECT DISTINCT ON(children_slugs.text)
                              children.id AS id,
                              children_slugs.text AS slug,
                              #{this}_child_roundels.url AS roundel_url,
                              children_order_tweets.text AS order_tweet,
                              #{this}_children_short_names.text AS order_short_name,
                              #{this}_children_titles.text AS title,
                              #{this}_children_memories.base_year AS base_year,
                              #{this}_children_events.happened_at AS happened_at,
                              #{this}_children_notes.text AS note,
                              json_agg(distinct #{this}_calendary_slugs.text) AS calendary_slugs
                         FROM memoes AS children
                         JOIN events AS #{this}_children_events
                           ON children.event_id = #{this}_children_events.id
                         JOIN memories AS #{this}_children_memories
                           ON #{this}_children_memories.id = #{this}_children_events.memory_id
                         JOIN slugs AS children_slugs
                           ON children_slugs.sluggable_id = #{this}_children_events.memory_id
                          AND children_slugs.sluggable_type = 'Memory'
                         JOIN calendaries AS #{this}_calendaries
                           ON #{this}_calendaries.id = memoes.calendary_id
                         JOIN slugs AS #{this}_calendary_slugs
                           ON #{this}_calendary_slugs.sluggable_id = #{this}_calendaries.id
                          AND #{this}_calendary_slugs.sluggable_type = 'Calendary'
                              #{cslugs_rule}
              LEFT OUTER JOIN descriptions AS #{this}_children_titles
                           ON #{this}_children_titles.describable_id = children.id
                          AND #{this}_children_titles.describable_type = 'Memo'
                          AND #{this}_children_titles.type = 'Title'
                          AND #{this}_children_titles.language_code IN ('#{language_codes.join("', '")}')
                          AND #{this}_children_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
              LEFT OUTER JOIN memo_orders AS children_memo_orders
                           ON children_memo_orders.memo_id = children.id
              LEFT OUTER JOIN memories AS children_orders
                           ON children_orders.id = children_memo_orders.order_id
                          AND children_orders.type = 'Order'
              LEFT OUTER JOIN short_names AS #{this}_children_short_names
                           ON children_orders.id = #{this}_children_short_names.memory_id
                          AND #{this}_children_short_names.language_code IN ('#{language_codes.join("', '")}')
                          AND #{this}_children_short_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
              LEFT OUTER JOIN descriptions AS children_order_tweets
                           ON children_order_tweets.describable_id = children_orders.id
                          AND children_order_tweets.describable_type = 'Memory'
                          AND children_order_tweets.type = 'Tweet'
                          AND children_order_tweets.language_code IN ('#{language_codes.join("', '")}')
                          AND children_order_tweets.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
              LEFT OUTER JOIN LATERAL (
                       SELECT #{this}_child_roundels.url AS url,
                              #{this}_child_roundels.roundelable_id AS id,
                              #{this}_child_roundels.roundelable_type AS type
                         FROM roundels AS #{this}_child_roundels
                        WHERE #{this}_child_roundels.url IS NOT NULL
                          AND (#{this}_children_events.memory_id = #{this}_child_roundels.roundelable_id
                          AND 'Memory' = #{this}_child_roundels.roundelable_type
                           OR #{this}_children_events.id = #{this}_child_roundels.roundelable_id
                          AND 'Event' = #{this}_child_roundels.roundelable_type)
                     ORDER BY random()
                        LIMIT 1) AS #{this}_child_roundels
                           ON #{this}_child_roundels.type IN ('Memory', 'Event')
              LEFT OUTER JOIN descriptions AS #{this}_children_notes
                           ON #{this}_children_notes.describable_id = children.id
                          AND #{this}_children_notes.describable_type = 'Memo'
                          AND #{this}_children_notes.type = 'Note'
                          AND #{this}_children_notes.language_code IN ('#{language_codes.join("', '")}')
                          AND #{this}_children_notes.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
                        WHERE children.bond_to_id = memoes.id
                          AND children.bind_kind_code = 'соборный'
                     GROUP BY children_slugs.text, #{this}_children_memories.base_year, happened_at, children.id, roundel_url, order_tweet, order_short_name, title, note
                     ORDER BY children_slugs.text, base_year
                        LIMIT 25)
                       SELECT jsonb_agg(__children)
                         FROM __children), '[]'::jsonb) AS children,
                              memo_titles.text AS title,
                              memo_descriptions.text AS description,
                              memo_links.url AS url,
                              calendary_links.url AS calendary_url,
                              calendary_slugs.text AS calendary_slug,
                              calendary_titles.text AS calendary_title
                         FROM memoes
                         JOIN calendaries
                           ON calendaries.id = memoes.calendary_id
                         JOIN slugs AS calendary_slugs
                           ON calendary_slugs.sluggable_id = calendaries.id
                          AND calendary_slugs.sluggable_type = 'Calendary'
                              #{cslugs_rule}
              LEFT OUTER JOIN events
                           ON memoes.event_id = events.id
                          AND events.kind_code IN ('#{Event::NOTICE.join("','")}')
              LEFT OUTER JOIN links AS calendary_links
                           ON calendary_links.info_id = calendaries.id
                          AND calendary_links.info_type = 'Calendary'
              LEFT OUTER JOIN descriptions AS memo_titles
                           ON memo_titles.describable_id = memoes.id
                          AND memo_titles.describable_type = 'Memo'
                          AND memo_titles.type = 'Title'
                          AND memo_titles.language_code IN ('#{language_codes.join("', '")}')
              LEFT OUTER JOIN descriptions AS memo_descriptions
                           ON memo_descriptions.describable_id = memoes.id
                          AND memo_descriptions.describable_type = 'Memo'
                          AND memo_descriptions.type = 'Description'
                          AND memo_descriptions.language_code IN ('#{language_codes.join("', '")}')
              LEFT OUTER JOIN links AS memo_links
                           ON memo_links.info_id = memoes.id
                          AND memo_links.info_type = 'Memo'
              LEFT OUTER JOIN descriptions AS calendary_titles
                           ON calendary_titles.describable_id = calendaries.id
                          AND calendary_titles.describable_type = 'Calendary'
                          AND calendary_titles.type = 'Appellation'
                          AND calendary_titles.language_code IN ('#{language_codes.join("', '")}')
              LEFT OUTER JOIN memo_orders
                           ON memo_orders.memo_id = memoes.id
              LEFT OUTER JOIN memories AS orders
                           ON orders.id = memo_orders.order_id
                          AND orders.type = 'Order'
              LEFT OUTER JOIN slugs AS memo_slugs
                           ON memo_slugs.sluggable_id = orders.id
                          AND memo_slugs.sluggable_type = 'Memory'
              LEFT OUTER JOIN memo_orders AS memo_orders_memoes_join
                           ON memo_orders_memoes_join.memo_id = memoes.id
              LEFT OUTER JOIN memories AS orders_memoes_join
                           ON orders_memoes_join.id = memo_orders_memoes_join.order_id
                          AND orders_memoes_join.type = 'Memory'
              LEFT OUTER JOIN descriptions AS order_titles_memoes
                           ON order_titles_memoes.describable_id = orders_memoes_join.id
                          AND order_titles_memoes.describable_type = 'Memory'
                          AND order_titles_memoes.type IN ('Tweet')
                          AND order_titles_memoes.language_code IN ('#{language_codes.join("', '")}')
                        WHERE events.memory_id = #{this}.id
                          AND memoes.bond_to_id IS NULL
                          AND memoes.id IS NOT NULL
                          AND calendaries.licit = 't'
                     GROUP BY memoes.id, year_date, title, description, calendary_slug,
                              calendary_title, calendary_url, memo_links.url, events.kind_code)
                       SELECT jsonb_agg(__memoes)
                         FROM __memoes), '[]'::jsonb) AS _memoes"

      select(selector).group(:id)
   end

   scope :with_bond_memories, ->(context) do
      this = table.table_alias || table.name
      language_codes = [context[:text_languages]].flatten
      alphabeth_codes = Languageble.alphabeth_list_for( language_codes ).flatten

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "COALESCE((WITH __bond_memories AS (
                      SELECT DISTINCT ON (#{this}_memory_binds.id)
                             #{this}_memory_binds.id AS id,
                             #{this}_memory_binds.kind AS kind,
                             #{this}_memory_slugs.text AS slug,
                             #{this}_order_tweets.text AS order,
                             #{this}_bond_short_names.text AS name
                        FROM memories AS #{this}_bond_memories
             LEFT OUTER JOIN slugs AS #{this}_memory_slugs
                          ON 'Memory' = #{this}_memory_slugs.sluggable_type
                         AND #{this}_bond_memories.id = #{this}_memory_slugs.sluggable_id
             LEFT OUTER JOIN memory_binds AS #{this}_memory_binds
                          ON #{this}_bond_memories.id = #{this}_memory_binds.bond_to_id
             LEFT OUTER JOIN short_names AS #{this}_bond_short_names
                          ON #{this}_bond_memories.id = #{this}_bond_short_names.memory_id
                         AND #{this}_bond_short_names.language_code IN ('#{language_codes.join("', '")}')
                         AND #{this}_bond_short_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
             LEFT OUTER JOIN events AS #{this}_events
                          ON #{this}.id = #{this}_events.memory_id
             LEFT OUTER JOIN memoes AS #{this}_memoes
                          ON #{this}_memoes.event_id = #{this}_events.id
             LEFT OUTER JOIN memo_orders AS #{this}_memo_orders
                          ON #{this}_memo_orders.memo_id = #{this}_memoes.id
             LEFT OUTER JOIN descriptions AS #{this}_order_tweets
                          ON #{this}_order_tweets.describable_id = #{this}_memo_orders.order_id
                         AND #{this}_order_tweets.describable_type = 'Memory'
                         AND #{this}_order_tweets.type = 'Tweet'
                         AND #{this}_order_tweets.language_code IN ('#{language_codes.join("', '")}')
                         AND #{this}_order_tweets.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
                       WHERE #{this}_memory_binds.memory_id = #{this}.id)
                      SELECT jsonb_agg(__bond_memories)
                        FROM __bond_memories), '[]'::jsonb) AS _bond_memories"

      select(selector).group(:id)
   end

   # https://efim360.ru/postgresql-tablicza-prisutstvuet-v-zaprose-no-soslatsya-na-neyo-iz-etoj-chasti-zaprosa-nelzya/?ysclid=lqs5tozisb568391387
   scope :with_icon, -> context do
      this = table.table_alias || table.name
      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "#{this}_roundels.url AS image_url"
      join = "LEFT OUTER JOIN LATERAL (
                      SELECT #{this}_roundels.url AS url,
                             #{this}_roundels.roundelable_id AS id,
                             #{this}_roundels.roundelable_type AS type
                        FROM roundels AS #{this}_roundels
             LEFT OUTER JOIN events AS #{this}_events
                          ON #{this}_events.memory_id = #{this}.id
                       WHERE #{this}_roundels.url IS NOT NULL
                         AND (#{this}.id = #{this}_roundels.roundelable_id
                         AND 'Memory' = #{this}_roundels.roundelable_type
                          OR #{this}_events.id = #{this}_roundels.roundelable_id
                         AND 'Event' = #{this}_roundels.roundelable_type)
                    ORDER BY random()
                       LIMIT 1) AS #{this}_roundels
                          ON #{this}_roundels.type IN ('Memory', 'Event')"

      joins(join).select(selector).group(:id, "#{this}_roundels.url")
   end

   scope :with_slug_text, -> _context do
      selector = self.select_values.dup
      if selector.empty?
         selector << 'memories.*'
      end
      selector << 'slugs.text AS _slug'

      left_outer_joins(:slug).select(selector.uniq).group('_slug').order('_slug')
   end

   scope :with_pure_slug, -> context do
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || "slug"
      asr = model.reflections[rela]&.name
      this = table.table_alias || table.name
      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "#{asr}_#{this}_slugs.text AS _#{as}"
      join = "LEFT OUTER JOIN slugs AS #{asr}_#{this}_slugs
                           ON #{asr}_#{this}_slugs.sluggable_id = #{this}.id
                          AND #{asr}_#{this}_slugs.sluggable_type = 'Memory'"

      joins(join).select(selector).group(:id, "#{asr}_#{this}_slugs.id", "#{asr}_#{this}_slugs.text")
   end

   scope :with_slug, -> _context do
      as = table.table_alias || table.name
      selector = self.select_values.dup
      selector << "#{as}.*" if selector.empty?
      selector << "jsonb_build_object(
         'id', #{as}_slugs.id,
         'text', #{as}_slugs.text) AS _slug"
      join = "LEFT OUTER JOIN slugs AS #{as}_slugs
                           ON #{as}_slugs.sluggable_id = #{as}.id
                          AND #{as}_slugs.sluggable_type = 'Memory'"

      joins(join).select(selector).group(:id, "#{as}_slugs.id", "#{as}_slugs.text")
   end

   scope :with_orders, -> context do
      language_codes = [context[:text_languages]].flatten
      selector = self.select_values.dup
      if self.select_values.dup.empty?
         selector << 'memories.*'
      end

      selector << "COALESCE((WITH __orders AS (
                       SELECT DISTINCT ON(orders.id)
                              orders.id AS id,
                              order_names.text AS name
                         FROM memories AS orders
                         JOIN memo_orders
                           ON memo_orders.order_id = orders.id
                          AND orders.type = 'Order'
                         JOIN memoes
                           ON memoes.id = memo_orders.memo_id
                         JOIN events
                           ON events.id = event_id
              LEFT OUTER JOIN descriptions AS order_names
                           ON order_names.describable_id = orders.id
                          AND order_names.describable_type = 'Memory'
                          AND order_names.language_code IN ('#{language_codes.join("', '")}')
                        WHERE events.memory_id = memories.id
                     GROUP BY orders.id, order_names.text)
                       SELECT jsonb_agg(__orders)
                         FROM __orders), '[]'::jsonb) AS _orders"

      select(selector).group(:id)
   end

   scope :with_attitude_to, -> context do
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || rela
      this = table.table_alias || table.name
      language_codes = [context[:text_language] || context[:text_languages]].flatten
      alphabeth_codes = [context[:codes] || context[:text_language] || Languageble.alphabeth_list_for(language_codes)].flatten

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "#{this}_#{as}_short_names.text AS _#{as}"

      join = "JOIN short_names AS #{this}_#{as}_short_names
                ON #{this}.id = #{this}_#{as}_short_names.memory_id
               AND #{this}_#{as}_short_names.language_code IN ('#{language_codes.join("', '")}')
               AND #{this}_#{as}_short_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"

      joins(join).select(selector).group(:id, "#{this}_#{as}_short_names.text")
   end

   scope :with_gallery_title, -> context do
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || rela
      this = table.table_alias || table.name
      language_codes = [context[:text_language] || context[:text_languages]].flatten
      alphabeth_codes = [context[:codes] || context[:text_language] || Languageble.alphabeth_list_for(language_codes)].flatten

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "COALESCE(#{as}_short_names.text, '') AS _gallery_title"

      join = "JOIN short_names AS #{as}_short_names
                ON #{this}.id = #{as}_short_names.memory_id
               AND #{as}_short_names.language_code IN ('#{language_codes.join("', '")}')
               AND #{as}_short_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"

      joins(join).select(selector).group(:id, "#{as}_short_names.text")
   end

   scope :with_orders, -> context do
      language_codes = [ context[:text_languages] ].flatten
      cslugs_rule = context[:calendary_slugs] ? "AND calendary_slugs.text IN ('#{context[:calendary_slugs].join("','")}')" : ""
      this = table.table_alias || table.name

      selector = "COALESCE((WITH __orders AS (
                       SELECT DISTINCT ON(memo_slugs.text)
                              COALESCE(memo_slugs.text, order_titles_memoes.text) AS slug,
                              order_titles_memoes.text AS name
                         FROM memories AS orders
              LEFT OUTER JOIN memoes
                           ON #{this}.id = memoes.event_id
              LEFT OUTER JOIN calendaries
                           ON calendaries.id = memoes.calendary_id
              LEFT OUTER JOIN slugs AS calendary_slugs
                           ON calendary_slugs.sluggable_id = calendaries.id
                          AND calendary_slugs.sluggable_type = 'Calendary'
                              #{cslugs_rule}
              LEFT OUTER JOIN memo_orders
                           ON memo_orders.memo_id = memoes.id
              LEFT OUTER JOIN slugs AS memo_slugs
                           ON memo_slugs.sluggable_id = orders.id
                          AND memo_slugs.sluggable_type = 'Memory'
              LEFT OUTER JOIN descriptions AS order_titles_memoes
                           ON order_titles_memoes.describable_id = orders.id
                          AND order_titles_memoes.describable_type = 'Memory'
                          AND order_titles_memoes.type IN ('Tweet')
                          AND order_titles_memoes.language_code IN ('#{language_codes.join("', '")}')
                        WHERE orders.id = memo_orders.order_id
                          AND orders.type = 'Order'
                          AND calendaries.licit = 't'
                     GROUP BY order_titles_memoes.text, memo_slugs.text)
                       SELECT jsonb_agg(__orders)
                         FROM __orders), '[]'::jsonb) AS _orders"

      #binding.pry
      select(selector).group(:id)
   end
   scope :with_events, -> context do
      this = table.table_alias || table.name
      language_codes = [context[:text_languages]].flatten.compact
      alphabeth_codes = Languageble.alphabeth_list_for(language_codes)
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = model.reflections[rela]&.name

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?

      if language_codes.any?
         lang_wheres = [
            "AND language_names.language_code IN ('#{language_codes.join("', '")}')",
            "AND titles.language_code IN ('#{language_codes.join("', '")}')",
            "AND descriptions.language_code IN ('#{language_codes.join("', '")}')",
            "AND place_names.language_code IN ('#{language_codes.join("', '")}')",
            "AND item_names.language_code IN ('#{language_codes.join("', '")}')",
            "AND #{this}_item_type_names.language_code IN ('#{language_codes.join("', '")}')",
            "AND event_kind_titles.language_code IN ('#{language_codes.join("', '")}')",
         ]
      end

      if alphabeth_codes.any?
         alph_wheres = [
            "AND alphabeth_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
            "AND titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
            "AND descriptions.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
            "AND place_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
            "AND item_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
            "AND #{this}_item_type_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
            "AND event_kind_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
         ]
      end

      selector << "COALESCE((WITH __events AS (
                      SELECT DISTINCT ON(events.id)
                             events.id AS id,
                             events.happened_at AS happened_at,
                             events.kind_code AS kind_code,
                             event_kind_titles.text AS kind_name,
                             events.place_id AS place_id,
                             place_names.text AS place,
                             events.item_id AS item_id,
                             COALESCE(item_names.text, #{this}_item_type_names.text) AS item,
                             events.person_name AS person_name,
                             events.type_number AS type_number,
                             events.about_string AS about_string,
                             events.tezo_string AS tezo_string,
                             events.order AS order,
                             events.council AS council,
              COALESCE((WITH __titles AS (
                      SELECT DISTINCT ON(titles.id)
                             titles.id AS id,
                             titles.text AS text,
                             titles.language_code AS language_code,
                             language_names.text AS language,
                             titles.alphabeth_code AS alphabeth_code,
                             alphabeth_names.text AS alphabeth
                        FROM descriptions AS titles
             LEFT OUTER JOIN subjects AS languages
                          ON languages.key = titles.language_code
             LEFT OUTER JOIN descriptions AS language_names
                          ON language_names.describable_id = languages.id
                         AND language_names.describable_type = 'Subject'
                             #{lang_wheres&.first}
             LEFT OUTER JOIN subjects AS alphabeths
                          ON alphabeths.key = titles.alphabeth_code
             LEFT OUTER JOIN descriptions AS alphabeth_names
                          ON alphabeth_names.describable_id = alphabeths.id
                         AND alphabeth_names.describable_type = 'Subject'
                             #{alph_wheres&.first}
                       WHERE titles.describable_id = events.id
                         AND titles.describable_type = 'Event'
                         AND titles.type = 'Title'
                             #{lang_wheres&.[](1)} #{alph_wheres&.[](1)}
                    GROUP BY titles.id, language_names.text, alphabeth_names.text)
                      SELECT jsonb_agg(__titles)
                        FROM __titles), '[]'::jsonb) AS titles,
              COALESCE((WITH __descriptions AS (
                      SELECT DISTINCT ON(descriptions.id)
                             descriptions.id AS id,
                             descriptions.text AS text,
                             descriptions.language_code AS language_code,
                             language_names.text AS language,
                             descriptions.alphabeth_code AS alphabeth_code,
                             alphabeth_names.text AS alphabeth
                        FROM descriptions
             LEFT OUTER JOIN subjects AS languages
                          ON languages.key = descriptions.language_code
             LEFT OUTER JOIN descriptions AS language_names
                          ON language_names.describable_id = languages.id
                         AND language_names.describable_type = 'Subject'
                             #{lang_wheres&.first}
             LEFT OUTER JOIN subjects AS alphabeths
                          ON alphabeths.key = descriptions.alphabeth_code
             LEFT OUTER JOIN descriptions AS alphabeth_names
                          ON alphabeth_names.describable_id = alphabeths.id
                         AND alphabeth_names.describable_type = 'Subject'
                             #{alph_wheres&.first}
                       WHERE descriptions.describable_id = events.id
                         AND descriptions.describable_type = 'Event'
                             #{lang_wheres&.[](2)} #{alph_wheres&.[](2)}
                         AND descriptions.type IN ('Description')
                    GROUP BY descriptions.id, language_names.text, alphabeth_names.text)
                      SELECT jsonb_agg(__descriptions)
                        FROM __descriptions), '[]'::jsonb) AS descriptions
                        FROM events
             LEFT OUTER JOIN descriptions AS place_names
                          ON place_names.describable_id = events.place_id
                         AND place_names.describable_type = 'Memory'
                             #{lang_wheres&.[](3)} #{alph_wheres&.[](3)}
             LEFT OUTER JOIN items AS #{this}_items
                          ON #{this}_items.id = events.item_id
             LEFT OUTER JOIN descriptions AS item_names
                          ON item_names.describable_id = #{this}_items.id
                         AND item_names.describable_type = 'Item'
                             #{lang_wheres&.[](4)} #{alph_wheres&.[](4)}
             LEFT OUTER JOIN descriptions AS #{this}_item_type_names
                          ON #{this}_item_type_names.describable_id = #{this}_items.item_type_id
                         AND #{this}_item_type_names.describable_type = 'ItemType'
                             #{lang_wheres&.[](5)} #{alph_wheres&.[](5)}
             LEFT OUTER JOIN subjects AS event_kinds
                          ON event_kinds.kind_code = 'EventKind'
                         AND event_kinds.key = events.kind_code
             LEFT OUTER JOIN descriptions AS event_kind_titles
                          ON event_kind_titles.describable_id = event_kinds.id
                         AND event_kind_titles.describable_type = 'Subject'
                         AND event_kind_titles.type = 'Appellation'
                             #{lang_wheres&.[](6)} #{alph_wheres&.[](6)}
                       WHERE events.memory_id = memories.id
                    GROUP BY events.id, place_names.text, item_names.text, #{this}_item_type_names.text, event_kind_titles.text)
                      SELECT jsonb_agg(__events)
                        FROM __events), '[]'::jsonb) AS _events"

      select(selector).group(:id)
   end

   scope :with_memory_names, -> context do
      this = table.table_alias || table.name
      language_codes = [context[:text_languages]].flatten.compact
      alphabeth_codes = Languageble.alphabeth_list_for(language_codes)
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = model.reflections[rela]&.name

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?

      if language_codes.any?
         lang_wheres = [
            "AND memory_name_state_titles.language_code IN ('#{language_codes.join("', '")}')",
         ]
      end

      if alphabeth_codes.any?
         alph_wheres = [
            "AND memory_name_state_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
         ]
      end

      selector = "COALESCE((
                        WITH __memory_names AS (
                      SELECT memory_names.id AS id,
                             nomina.id AS nomen_id,
                             names.text || COALESCE(' < ' || bond_toes.text, '') || ' (' || names.language_code|| '_' || names.alphabeth_code || ')' AS name,
                             memory_names.state_code AS state_code,
                             memory_name_state_titles.text AS state_name,
                             memory_names.mode AS mode,
                             memory_names.feasible AS feasible
                        FROM memory_names
             LEFT OUTER JOIN subjects AS memory_name_states
                          ON memory_name_states.key = memory_names.state_code
             LEFT OUTER JOIN descriptions AS memory_name_state_titles
                          ON memory_name_state_titles.describable_id = memory_name_states.id
                         AND memory_name_state_titles.describable_type = 'Subject'
                             #{lang_wheres&.first} #{alph_wheres&.first}
             LEFT OUTER JOIN nomina
                          ON nomina.id = memory_names.nomen_id
             LEFT OUTER JOIN names
                          ON names.id = nomina.name_id
             LEFT OUTER JOIN names AS bond_toes
                          ON bond_toes.id = nomina.bond_to_id
                       WHERE memory_names.memory_id = memories.id
                         AND memory_names.id IS NOT NULL
                    GROUP BY memory_names.id, names.text, bond_toes.text, memory_name_state_titles.text, names.language_code, names.alphabeth_code, nomina.id)
                      SELECT jsonb_agg(__memory_names)
                        FROM __memory_names), '[]'::jsonb) AS _memory_names"

      select(selector).group(:id)
   end

   singleton_class.send(:alias_method, :t, :by_token)
   singleton_class.send(:alias_method, :d, :by_date)
   singleton_class.send(:alias_method, :c, :in_calendaries)

   accepts_nested_attributes_for :short_names, reject_if: :all_blank, allow_destroy: true
   accepts_nested_attributes_for :memory_binds, reject_if: :all_blank, allow_destroy: true
   accepts_nested_attributes_for :memory_names, reject_if: :all_blank, allow_destroy: true
   accepts_nested_attributes_for :paterics, reject_if: :all_blank, allow_destroy: true
   accepts_nested_attributes_for :events, reject_if: :all_blank, allow_destroy: true
   accepts_nested_attributes_for :memos, reject_if: :all_blank, allow_destroy: true
   accepts_nested_attributes_for :coverings, reject_if: :all_blank, allow_destroy: true
   accepts_nested_attributes_for :notes, reject_if: :all_blank, allow_destroy: true
   accepts_nested_attributes_for :slug, reject_if: :all_blank

   validates_presence_of :short_names
   validates :base_year, format: { with: /\A-?\d+\z/ }
   validates :quantity, format: { with: /\A[0-9?+]+?\z/ }, allow_blank: true

   before_create :set_slug
   before_validation :set_base_year, on: :create

   def all_pictures
     pictures.or(Picture.by_event(events))
   end

   def set_base_year
      types = %w(Resurrection Repose Writing Appearance Translation Sanctification)

      event = self.events.to_a.sort_by { |x| (types.index(x.kind) || 100) }.first

      return unless event

      dates = event.happened_at.split(/[\/-]/)
      self.base_year ||=
         case dates.first
         when /([IVX]+)$/
            ($1.rom - 1) * 100 + 50
         when /\.\s*(\d+)$/
            $1
         when /(?:\A|\s|\()(\d+)$/
            $1
         when /(?:\A|\s|\(|\.)(\d+) до (?:нэ|РХ)/
            "-#{$1}"
         when /(:|сент)/
            dates.last.split(".").last
         when /давно/
            '-3760'
         else
            dates = event.happened_at.split(/[\/-]/)
            if /(?:\A|\s|\(|\.)(\d+) до (?:нэ|РХ)/ =~ dates.first
               "-#{$1}"
            else
               '0'
            end
         end

      self.base_year
   end

   def quantity= value_in
      value = value_in.present? && value_in || nil

      super(value)
   end

   def slug= value_in
      value =
         case value_in
         when NilClass
            nil
         when String
            self.slug ? self.slug.assign_attributes(text: value_in) : Slug.new(text: value_in)
         else
            value_in
         end || self.slug

      super(value)
   end

   def set_slug
      self.slug = Slug.new(base: self.short_names.first.text) if self.slug.blank?
   end

   def to_s
      memory_names.join( ' ' )
   end

   def short_name_for context = {}
      language_codes = [context[:text_languages]].flatten.compact
      alphabeth_codes = context[:codes] || Languageble.alphabeth_list_for(language_codes)

      short_name(language_codes, alphabeth_codes)
   end

   def short_name language_code = nil, alphabeth_code = nil
      attrs = %w(language_code alphabeth_code).map {|x| [x, eval(x)] }.select {|(_,v)| v }.to_h

      short_names.where(attrs).first&.text
   end

   def short_name= short_name
      sn = ShortName.new(text: short_name)

      if sn.valid?
         if sno = short_names.where(language_code: "ср", alphabeth_code: "СР").first
            sno.update!(text: short_name)
         else
            short_names << sn
         end
      else
         errors.add(:short_names, "Unable to cerate invalid short name: '#{short_name}'")
      end
   end
end
