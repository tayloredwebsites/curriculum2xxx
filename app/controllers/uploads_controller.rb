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
      render :do_upload
    else
      flash[:notice] = 'Missing upload record.'
      index_prep
      render :index
    end
  end

  def do_upload
    require 'csv'
    if @upload
      case @upload.status
      when Upload::UPLOAD_STATUS_NOT_UPLOADED
        puts("status Upload::UPLOAD_STATUS_NOT_UPLOADED, #{Upload::UPLOAD_STATUS[Upload::UPLOAD_STATUS_NOT_UPLOADED]}")
        puts("method: #{request.method}")
        filename = 'Hem_09_transl_Eng.csv'
        puts("upload_params: #{upload_params}")
        if upload_params['file'].original_filename == filename
          # process file to upload

          # these are the OCT headers we need (rest are for teacher uploads) in the spreadsheet
          long_headers = [ "Area", "Component ", "Outcome", "Indicator", "Grade band", "relevant KBE sectors (as determined from KBE spreadsheets)", "Explanation of how the indicator relates to KBE sector", "Closely related learning outcomes applicable to KBE sector", "Mathematics", "Geography", "Physics", "Biology", "ICT" ]
          # OCT headers as symbols
          # todo - confirm that eighth header is chemistry - same subject as file ????
          # todo - may need different set of arrays, or mappings for other subjects.
          short_headers = [ :area, :component, :outcome, :indicator, :gradeBand, :relevantKbe, :kbeRelation, :chemistry, :mathematics, :geography, :physics, :biology, :computers]
          long_to_short = Hash[long_headers.zip(short_headers)]
          short_to_long = Hash[short_headers.zip(long_headers)]

          # saved records to avoid extra lookups
          area_rec = nil
          component_rec = nil
          outcome_rec = nil

          # CSV.foreach(upload_params['file'].path, headers: short_headers) do |row|
          CSV.foreach(upload_params['file'].path, headers: true) do |row|
            # puts "original row: #{row.inspect}"
            # map original rows to short headers for standardized field lookup in row
            # new_row = Hash.new()

            row.each do |key, val|
              new_key = long_to_short[key]
            #   new_row[long_to_short[key]] = val if new_key
            # end
            # puts "new row: #{new_row.inspect}"
            # new_row.each do |new_key, val| do
              case new_key
              when :area
                # Area record formatting: "AREA #: <name>""
                area_label = val.split(/:/).first
                area_num = area_label.gsub(/[^0-9,.]/, "")
                raise "invalid area code: #{area_num.inspect}" if area_num.length != 1

                # insert area into tree
                node = Tree.find_or_add_code_in_tree(Tree::OTC_TREE_TYPE_ID, Tree::OTC_VERSION_ID, @upload.subject_id, @upload.grade_band_id, area_num.to_s, nil, (area_rec ? area_rec.code : ''), area_rec)
                area_rec = node

                # insert area name into translation table
                # transl = Translation.find_or_add_translation(locale, "#{OTC_TRANSLATION_START}.#{@upload.subject.code}.#{@upload.grade_band.code}.#{node.code}.name", val)
              end # case new_key
            end # row.each
          end
        else
          flash[:notice] = 'Filename does not match this Upload!'
        end
        render :do_upload
      when Upload::UPLOAD_STATUS_TREE_UPLOADED
        puts("status UPLOAD_STATUS_TREE_UPLOADED, #{Upload::UPLOAD_STATUS[Upload::UPLOAD_STATUS_TREE_UPLOADED]}")
      when Upload::UPLOAD_STATUS_UPLOAD_DONE
        puts("status UPLOAD_STATUS_UPLOAD_DONE, #{Upload::UPLOAD_STATUS[Upload::UPLOAD_STATUS_UPLOAD_DONE]}")
      else
        puts("invalid status")
      end
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
