#These are functions that work with real active record objects that are analogs of other helper functions
#that rely on solr objects
#Many of these are from SharedHelper, but I'll accumulate them from anywhere into here
module ProperSharedHelper
  def proper_link_to_saved(work, saved)
    if saved and saved.items and saved.items.include?(work.id)
      content_tag(:strong, "#{t 'app.saved'} - ") +
          link_to(t('app.remove'), remove_from_saved_work_url(work.id))
    else
      link_to t('app.save'), add_to_saved_work_url(work.id)
    end
  end

  def proper_link_to_authors(work)
    proper_name_string_links(work.authors, '', '', work)
  end

  def proper_link_to_editors(work)
    proper_name_string_links(work.editors, work.authors.present? ? (t('common.shared.in') + ' ') : '',
                             " (#{t 'common.shared.eds'})", work)
  end

  def proper_name_string_links(people_hashes, prefix, postfix, work)
    return '' if people_hashes.blank?
    links = people_hashes.first(5).collect do |hash|
      link_to(h("#{hash[:name].gsub(",", ", ")}"), name_string_path(hash[:id]), {:class => "name_string"})
    end
    if people_hashes.size > 5
      links << link_to(t('common.shared.more'), work_path(work.id))
    end
    return [prefix, links.join("; "), postfix].join.html_safe
  end

  def proper_link_to_work_publication(work)
    proper_link_to_work_pub_common(work.publication, Publication, :publication_path)
  end

  def proper_link_to_work_publisher(work)
    proper_link_to_work_pub_common(work.publisher, Publisher, :publisher_path)
  end

  def proper_link_to_work_pub_common(pub, klass, path_helper_name)
    return t('app.unknown') if pub.blank?
    link_to("#{name_or_unknown(pub.name)}", self.send(path_helper_name, pub.id), {:class => "source"})
  end

  def proper_subclass_partial_for(work)
    file_name = "shared/proper_work_subclasses/#{work.class.to_s.underscore}"
    File.exists?(File.join(Rails.root, 'app', 'views', file_name)) ? file_name : 'shared/proper_work_subclasses/generic'
  end

end