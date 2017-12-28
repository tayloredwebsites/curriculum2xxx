class UploadsController < ApplicationController
  before_action :find_upload, only: [:show, :edit, :update, :start_upload, :do_upload]
  def index
    index_prep
    respond_to do |format|
      format.html
      format.json { render json: @uploads}
    end
  end

  # def index2
  #   uploads = Upload.includes([:subject, :grade_band, :locale]).all.upload_listing
  # end

  def new
    @upload = Upload.new()
  end

  def create
    @upload = Upload.new(upload_params)
    if @upload.save
      flash[:success] = "Upload for #{ @upload.subject.code } #{ @upload.grade_band.code } #{ @upload.locale.name } updated."
      redirect_to uploads_url()
    end
  end

  def show
  end

  def edit
  end

  def update
    if @upload.update(upload_params)
      flash[:notice] = "Upload for #{ @upload.subject.code } #{ @upload.grade_band.code } #{ @upload.locale.name } updated."
      redirect_to uploads_url()
    else
      render :edit
    end
  end

  def start_upload
    if @upload
      @message = "Select file to upload to get to next step"
      @errs = []
      @rptRecs = []
      render :do_upload
    else
      flash[:notice] = 'Missing upload record.'
      index_prep
      render :index
    end
  end

  def do_upload
    require 'csv'

    # infomation to send back to user after completion
    row_num = 0
    @message = "Select file to upload to get to next step"
    @errs = []
    @rptRecs = []
    abort = false

    if @upload
      tree_parent_code = ''
      tree_parent_id = ''
      # to do - refactor this
      case @upload.status
      when ApplicationRecord::UPLOAD_STATUS_NOT_UPLOADED, ApplicationRecord::UPLOAD_STATUS_TREE_UPLOADING
        puts("Upload tree, #{ApplicationRecord::UPLOAD_STATUS[@upload.status]}")
        puts("method: #{request.method}")
        filename = 'Hem_09_transl_Eng.csv'
        puts("upload_params: #{upload_params}")

        if upload_params['file'].original_filename == filename
          # process file to upload

          # map csv headers to short symbols
          long_to_short = Upload.get_long_to_short()

          # saved parent records to avoid extra lookups
          area_rec = nil
          area_ids = []
          num_area_errors = 0
          component_rec = nil
          component_ids = []
          num_component_errors = 0
          outcome_rec = nil
          outcome_ids = []
          num_outcome_errors = 0
          indicator_ids = []
          num_indicator_errors = 0

          CSV.foreach(upload_params['file'].path, headers: true) do |row|
            # process this row
            row.each do |key, val|
              row_num += 1
              new_key = long_to_short[key]
              # process this column for this row
              case new_key
              when :area
                # Area record formatting: "AREA #: <name>""
                area_label = val.split(/:/).first
                area_num = area_label.gsub(/[^0-9,.]/, "")
                raise "row number #{row_num} has invalid area code at : #{area_num.inspect}" if area_num.length != 1

                # insert area into tree
                new_code, node, save_status, message = Tree.find_or_add_code_in_tree(
                  ApplicationRecord::OTC_TREE_TYPE_ID,
                  ApplicationRecord::OTC_VERSION_ID,
                  @upload.subject_id,
                  @upload.grade_band_id,
                  area_num.to_s,
                  nil,
                  area_rec
                )
                if save_status != ApplicationRecord::SAVE_STATUS_SKIP
                  # save this record for parent of component.
                  area_rec = node
                  area_ids << area_rec.id if !area_ids.include?(area_rec.id)
                  puts "area_ids: #{area_ids.inspect}"
                  rptRec = Array.new(4, '')
                  rptRec[ApplicationRecord::OTC_TREE_AREA] = area_num.to_s
                  rptRec << new_code
                  rptRec << '' # translated name of item.
                  rptRec << ApplicationRecord::SAVE_STATUS[save_status]
                  @rptRecs << rptRec
                  if save_status == ApplicationRecord::SAVE_STATUS_ERROR
                    @errs << message
                    num_area_errors += 1
                  end
                end
              when :component

                # insert area name into translation table
                # transl = Translation.find_or_add_translation(locale, "#{OTC_TRANSLATION_START}.#{@upload.subject.code}.#{@upload.grade_band.code}.#{node.code}.name", val)
              end # case new_key
            end # row.each
          end
        else
          flash[:alert] = 'Filename does not match this Upload!'
          abort = true
        end
      when ApplicationRecord::UPLOAD_STATUS_TREE_UPLOADED
        puts("status UPLOAD_STATUS_TREE_UPLOADED, #{ApplicationRecord::UPLOAD_STATUS[ApplicationRecord::UPLOAD_STATUS_TREE_UPLOADED]}")
        abort = true
      when ApplicationRecord::UPLOAD_STATUS_DONE
        puts("status UPLOAD_STATUS_DONE, #{ApplicationRecord::UPLOAD_STATUS[ApplicationRecord::UPLOAD_STATUS_DONE]}")
        abort = true
      else
        puts("invalid status #{@upload.status}")
        puts("ApplicationRecord::UPLOAD_STATUS_NOT_UPLOADED: #{ApplicationRecord::UPLOAD_STATUS_NOT_UPLOADED}")
        puts("ApplicationRecord::UPLOAD_STATUS_TREE_UPLOADING: #{ApplicationRecord::UPLOAD_STATUS_TREE_UPLOADING}")
        abort = true
      end
    end
    if abort
      render :index
    else
      if num_area_errors == 0 && area_ids.count > 0
        @upload.status = ApplicationRecord::UPLOAD_STATUS_TREE_UPLOADING
        @upload.status_detail = ApplicationRecord::OTC_TREE_LABELS[ApplicationRecord::OTC_TREE_AREA]
        if num_component_errors == 0 && component_ids.count > 0
          @upload.status_detail = ApplicationRecord::OTC_TREE_LABELS[ApplicationRecord::OTC_TREE_COMPONENT]
          if num_outcome_errors == 0 && outcome_ids.count > 0
            @upload.status_detail = ApplicationRecord::OTC_TREE_LABELS[ApplicationRecord::OTC_TREE_OUTCOME]
            if num_indicator_errors == 0 && indicator_ids.count > 0
              @upload.status_detail = ApplicationRecord::OTC_TREE_LABELS[ApplicationRecord::OTC_TREE_INDICATOR]
              @upload.status = ApplicationRecord::UPLOAD_STATUS_TREE_UPLOADED
            end
          end
        end
        @upload.save
      end
      render :do_upload
    end
  end

  private

  def find_upload
    @upload = Upload.find(params[:id])
  end

  def upload_params
    params.require('upload').permit(:subject_id, :grade_band_id, :locale_id, :status, :file)
  end

  def index_prep
    @uploads = Upload.includes([:subject, :grade_band, :locale]).all.upload_listing
  end

end
