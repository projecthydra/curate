#require Hydra::Collections::Engine.root + '/app/helpers/collections_helper.rb'
# View Helpers for Hydra Collections functionality
module Curate::CollectionsHelper 
  
  # Displays the Collections create collection button.
  def button_for_create_new_collection(label = 'Create Collection')
    render partial: 'button_create_collection', locals:{label:label}
  end

  def hidden_collection_members
    _erbout = ''
    if params[:batch_document_ids].present?
      params[:batch_document_ids].each do |batch_item|
        _erbout.concat hidden_field_tag("batch_document_ids[]", batch_item)
      end
    end
    _erbout.html_safe
  end

  def has_any_collections?
    current_user.collections.count > 0
  end

  def list_items_in_collection(collection, terminate=false)
    content_tag :ul do
      collection.members.inject('') do |output, member|
        output << member_line_item(member, terminate)
      end.html_safe
    end
  end

  def member_line_item(member, terminate)
    content_tag :li do
      member.respond_to?(:members) ? collection_line_item(member, terminate) : work_line_item(member)
    end
  end

  def work_line_item(work)
    link = link_to work.title, polymorphic_path_for_asset(work)
    contributors = work.contributor.empty? ? '' : "(#{work.contributor.join(', ')})"
    link + ' ' + contributors
  end

  def collection_line_item(collection, terminate)
    list_item = link_to(collection.to_s, collection_path(collection))
    list_item << list_items_in_collection(collection, true) unless terminate  # limit nesting
    list_item
  end

end

