class Person < ActiveRecord::Base
  has_many :name_strings, :through => :pen_names
  has_many :pen_names
  has_many :groups, :through => :memberships
  has_many :memberships
  
  # Association Extensions - Read more here:
  # http://blog.hasmanythrough.com/2006/3/1/association-goodness-2
  
  has_many :citations, :through => :contributorships do 
    
    def verified
      # ContributorshipStateId 2 = Verifed
      find(:all, :conditions => ["contributorships.contributorship_state_id = ?", 2])
    end
    
    def denied
      # ContributorshipStateId 3 = Denied
      find(:all, :conditions => ["contributorships.contributorship_state_id = ?", 3])
    end
  end
  
  has_many :contributorships do 
    # Show only non-hidden contributorships
    # @TODO: Maybe include a "score" threshold here as well?
    # - Like > 50 we show on the person view, 'cuz they probably wrote it?
    # - Like < 50 we don't show, 'cuz maybe they didn't write it?
    def to_show 
      find(:all, :conditions => ["contributorships.hide = ?", false])
    end
  end
  
  has_one :image, :as => :asset


  def name
    "#{first_name} #{last_name}"
  end
  
  def first_last
    "#{first_name} #{last_name}"
  end
  
  def to_param
    param_name = first_last.gsub(" ", "_")
    param_name = param_name.gsub(/[^A-Za-z0-9_]/, "")
    "#{id}-#{param_name}"
  end
  

  def groups_not
    all_groups = Group.find(:all, :order => "name")
    # TODO: do this right. The vector subtraction is dumb.
    return all_groups - groups
  end
  
  def name_strings_not
    suggestions = NameString.find(
      :all, 
      :conditions => ["name like ?", "%" + self.last_name + "%"],
      :order => :name
    )
    
    # TODO: do this right. The vector subtraction is dumb.
    return suggestions - name_strings
  end
  
  # Person Contributorship Calculation Fields
  def verified_publications
    Contributorship.find_all_by_person_id_and_contributorship_state_id(self.id,2)
  end
  
  def known_years
    # Build an array of verified publication year strings
    # Ex. ["2001,2002,..."]
    self.verified_publications.collect{|vp| vp.citation.year}.uniq
  end
  
  def known_publication_ids
    # Build an array of verified publication objects
    # Ex. [#<Publication id: 1...>,#<Publication id: 2...>,..."]
    self.verified_publications.collect{|vp| vp.citation.publication.id}.uniq
  end
  
  def known_collaborator_ids
    # Build an array of verified name_string objects
    # Ex. [#<NameString id: 1...>,#<NameString id: 2...>,..."]    
    self.verified_publications.collect{|vp| vp.citation.name_strings.collect{|ns| ns.id}}.flatten.uniq
  end
  
  def known_keyword_ids
    # Build an array of verified keyword objects
    # Ex. [#<Keyword id: 1...>,#<Keyword id: 2...>,..."]
    self.verified_publications.collect{|vp| vp.citation.keywords.collect{|k| k.id}}.flatten.uniq
  end
  
  def scoring_hash
    # Return a hash comprising all the Contributorship scoring methods
    scoring_hash = {
      :years => self.known_years, 
      :publication_ids => self.known_publication_ids,
      :collaborator_ids => self.known_collaborator_ids,
      :keyword_ids => self.known_keyword_ids
    }
    scoring_hash
  end
end