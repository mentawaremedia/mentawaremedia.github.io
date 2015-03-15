# Tag Cloud for Octopress, modified by pf_miles, for use with utf-8 encoded blogs(all regexp added 'u' option).
# modified by alswl, tag_cloud -> tag_cloud
# =======================
# 
# Description:
# ------------
# Easy output tag cloud and tag list.
# 
# Syntax:
# -------
#     {% tag_cloud [counter:true] %}
#     {% tag_list [counter:true] %}
# 
# Example:
# --------
# In some template files, you can add the following markups.
# 
# ### source/_includes/custom/asides/tag_cloud.html ###
# 
#     <section>
#       <h1>Tag Cloud</h1>
#         <span id="tag-cloud">{% tag_cloud %}</span>
#     </section>
# 
# ### source/_includes/custom/asides/tag_list.html ###
# 
#     <section>
#       <h1>Tags</h1>
#         <ul id="tag-list">{% tag_list counter:true %}</ul>
#     </section>
# 
# Notes:
# ------
# Be sure to insert above template files into `default_asides` array in `_config.yml`.
# And also you can define styles for 'tag-cloud' or 'tag-list' in a `.scss` file.
# (ex: `sass/custom/_styles.scss`)
# 
# Licence:
# --------
# Distributed under the [MIT License][MIT].
# 
# [MIT]: http://www.opensource.org/licenses/mit-license.php
# 
module Jekyll

  class TagCloud < Liquid::Tag

    def initialize(tag_name, markup, tokens)
      @opts = {}
      if markup.strip =~ /\s*counter:(\w+)/iu
        @opts['counter'] = ($1 == 'true')
        markup = markup.strip.sub(/counter:\w+/iu,'')
      end
      super
    end

    def render(context)
      lists = {}
      max, min = 1, 1
      config = context.registers[:site].config
      tag_dir = config['root'] + config['tag_dir'] + '/'
      tags = context.registers[:site].tags
      tags.keys.sort_by{ |str| str.downcase }.each do |tag|
        count = tags[tag].count
        lists[tag] = count
        max = count if count > max
      end

      html = ''
      lists.each do | tag, counter |
        url = tag_dir + tag.gsub(/_|\P{Word}/u, '-').gsub(/-{2,}/u, '-').downcase
        padding = (Float(counter)/max) * 0.5

        style = []
        style << "font-size: #{100 + (60 * Float(counter)/max)}%"
        style << "padding: #{padding}em #{padding}em #{padding}em #{padding}em"
        html << "<a href='#{url}' style='#{style.join("; ")}'>#{tag}"
        if @opts['counter']
          html << "(#{tags[tag].count})"
        end
        html << "</a> "
      end
      html
    end
  end

  class TagList < Liquid::Tag

    def initialize(tag_name, markup, tokens)
      @opts = {}
      if markup.strip =~ /\s*counter:(\w+)/iu
        @opts['counter'] = ($1 == 'true')
        markup = markup.strip.sub(/counter:\w+/iu,'')
      end
      super
    end

    def render(context)
      html = ""
      config = context.registers[:site].config
      tag_dir = config['root'] + config['tag_dir'] + '/'
      tags = context.registers[:site].tags
      tags.keys.sort_by{ |str| str.downcase }.each do |tag|
        url = tag_dir + tag.gsub(/_|\P{Word}/u, '-').gsub(/-{2,}/u, '-').downcase
        html << "<li style='#{li_styles}'><a href='#{url}'>#{tag}"
        if @opts['counter']
          html << " (#{tags[tag].count})"
        end
        html << "</a></li>"
      end
      html
    end

    def li_styles
      #style="float: left; line-height: 0.5em; width: 50%; margin: 0 0 .5em 0; padding: .5em 0;"
      styles = []
      styles << "float: left"
      styles << "line-height: 0.5em"
      styles << "width: 50%"
      styles << "margin: 0 0 .5em 0"
      styles << "padding: .5em 0"

      styles.join("; ")
    end
  end

end

Liquid::Template.register_tag('tag_cloud', Jekyll::TagCloud)
Liquid::Template.register_tag('tag_list', Jekyll::TagList)