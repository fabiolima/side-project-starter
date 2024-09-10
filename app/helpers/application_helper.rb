# frozen_string_literal: true

require "uri"

# Global helpers
module ApplicationHelper
  include Pagy::Frontend

  def active_link_to(text = nil, path = nil, active_classes: "", **options, &)
    path ||= text

    classes = active_classes.presence || "font-bold underline"
    options[:class] = class_names(options[:class], classes) if current_page?(path)

    return link_to(path, options, &) if block_given?

    link_to text, path, options
  end

  def path_from_url(url)
    url.nil? ? "" : URI.parse(url).path
  end

  def number_to_currency_br(number)
    number_to_currency(number, unit: "R$ ", separator: ",", delimiter: ".")
  end

  def admin_dashboard_links
    [
      { label: "Dashboard", path: admin_dashboard_path, icon: "home" },
      { label: "Users", path: admin_dashboard_users_path, icon: "users" },
      { label: "Products", path: admin_dashboard_products_path, icon: "squares-2x2" }
    ]
  end

  def icon(name, options = {})
    options[:title] ||= name.underscore.humanize
    options[:aria] = true
    options[:nocomment] = true
    options[:variant] ||= :outline
    options[:class] = options.fetch(:classes, nil)
    path = options.fetch(:path, "icons/#{options[:variant]}/#{name}.svg")
    icon = path
    inline_svg_tag(icon, options)
  end
end
