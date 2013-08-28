class CurationConcern::GenericWorksController < CurationConcern::BaseController
  respond_to(:html)
  with_themed_layout '1_column'

  def curation_concern
    @curation_concern ||=
    if params[:id]
      GenericWork.find(params[:id])
    else
      GenericWork.new(params[:generic_work])
    end
  end

  def new
  end

  def create
    if verify_acceptance_of_user_agreement!
      @curation_concern = GenericWork.new(pid: CurationConcern.mint_a_pid)
      begin
        actor.create!
        respond_for_create
      rescue ActiveFedora::RecordInvalid
        respond_with([:curation_concern, curation_concern]) do |wants|
          wants.html { render 'new', status: :unprocessable_entity }
        end
      end
    end
  end

  def respond_for_create
    if params[:commit] == save_and_add_related_files_submit_value
      respond_to do |wants|
        wants.html {
          redirect_to new_curation_concern_generic_file_path(curation_concern)
        }
      end
    else
      respond_with([:curation_concern, curation_concern])
    end
  end
  protected :respond_for_create

  def verify_acceptance_of_user_agreement!
    if contributor_agreement.is_being_accepted?
      return true
    else
      # Calling the new action to make sure we are doing our best to preserve
      # the input values; Its a stretch but hopefully it'll work
      self.new
      respond_with([:curation_concern, curation_concern]) do |wants|
        wants.html {
          flash.now[:error] = "You must accept the contributor agreement"
          render 'new', status: :conflict
        }
      end
      return false
    end
  end
  protected :verify_acceptance_of_user_agreement!

  def show
    respond_with(curation_concern)
  end

  def edit
    respond_with(curation_concern)
  end

  def update
    actor.update!
    if curation_concern.visibility_changed?
      redirect_to confirm_curation_concern_permission_path(curation_concern)
    else
      respond_with([:curation_concern, curation_concern])
    end
  rescue ActiveFedora::RecordInvalid
    respond_with([:curation_concern, curation_concern]) do |wants|
      wants.html { render 'edit', status: :unprocessable_entity }
    end
  end

  def destroy
    title = curation_concern.to_s
    curation_concern.destroy
    flash[:notice] = "Deleted #{title}"
    respond_with { |wants|
      wants.html { redirect_to dashboard_index_path }
    }
  end

  include Morphine
  register :actor do
    CurationConcern.actor(curation_concern, current_user, params[:generic_work])
  end
end
