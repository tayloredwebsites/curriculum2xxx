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
      when ApplicationRecord::UPLOAD_STATUS_NOT_UPLOADED,
        ApplicationRecord::UPLOAD_STATUS_TREE_UPLOADING,
        ApplicationRecord::UPLOAD_STATUS_TREE_UPLOADED
        filename = 'Hem_09_transl_Eng.csv'

        if upload_params['file'].original_filename == filename
          # process file to upload

          # map csv headers to short symbols
          long_to_short = Upload.get_long_to_short()

          # saved parent (tree stack) records to avoid extra lookups, etc.
          recs_stack = Array.new(4) {nil} # replace area_rec, component_rec, ...
          num_errors_stack = Array.new(4) {0}
          ids_stack = Array.new(4) {[]} # array of ids for tree stack array

          CSV.foreach(upload_params['file'].path, headers: true) do |row|
            codes_stack = Array.new(4) {''}
            row_num += 1

            # process this row
            row.each do |key, val|
              new_key = long_to_short[key]
              # process this column for this row
              depth = nil
              case new_key
              when :area
                depth = 0
              when :component
                depth = 1
              when :outcome
                depth = 2
              when :indicator
                depth = 3
              end
              if depth.present?
                code_str = parseSubCode(val, depth)
                raise "row number #{row_num}, depth: #{depth} has invalid area code at : #{code_str.inspect}" if code_str.length != 1

                # insert area into tree

                codes_stack[depth] = code_str # save curreant code in codes stack
                new_code, node, save_status, message = Tree.find_or_add_code_in_tree(
                  ApplicationRecord::OTC_TREE_TYPE_ID,
                  ApplicationRecord::OTC_VERSION_ID,
                  @upload.subject_id,
                  @upload.grade_band_id,
                  buildFullCode(codes_stack, depth),
                  nil,
                  recs_stack[depth]
                )
                if save_status != ApplicationRecord::SAVE_STATUS_SKIP
                  recs_stack[depth] = node
                  ids_stack[depth] << node.id if !ids_stack[depth].include?(node.id)
                  rptRec = codes_stack.clone # code stack for first four columns of report
                  rptRec << new_code
                  rptRec << '' # translated name of item.
                  rptRec << ApplicationRecord::SAVE_STATUS[save_status]
                  @rptRecs << rptRec
                  if save_status == ApplicationRecord::SAVE_STATUS_ERROR
                    @errs << message
                    num_errors_stack[depth] += 1
                  end
                end

                # insert area name into translation table
                # transl = Translation.find_or_add_translation(locale, "#{OTC_TRANSLATION_START}.#{@upload.subject.code}.#{@upload.grade_band.code}.#{node.code}.name", val)
              end # case new_key
            end # row.each
          end
        else
          flash[:alert] = 'Filename does not match this Upload!'
          abort = true
        end
      when ApplicationRecord::UPLOAD_STATUS_DONE
        puts("status UPLOAD_STATUS_DONE, #{ApplicationRecord::UPLOAD_STATUS[ApplicationRecord::UPLOAD_STATUS_DONE]}")
        abort = true
        @upload = []
      else
        puts("invalid status #{@upload.status}")
        puts("ApplicationRecord::UPLOAD_STATUS_NOT_UPLOADED: #{ApplicationRecord::UPLOAD_STATUS_NOT_UPLOADED}")
        puts("ApplicationRecord::UPLOAD_STATUS_TREE_UPLOADING: #{ApplicationRecord::UPLOAD_STATUS_TREE_UPLOADING}")
        abort = true
        @upload = []
      end
    end
    if abort
      render :index
    else
      puts "num_errors_stack: #{num_errors_stack.inspect}"
      puts "ids_stack[0]: #{ids_stack[0].inspect}"
      if num_errors_stack[0] == 0 && ids_stack[0].count > 0
        @upload.status = ApplicationRecord::UPLOAD_STATUS_TREE_UPLOADING
        @upload.status_detail = ApplicationRecord::OTC_TREE_LABELS[ApplicationRecord::OTC_TREE_AREA]
        if num_errors_stack[1] == 0 && ids_stack[1].count > 0
          @upload.status_detail = ApplicationRecord::OTC_TREE_LABELS[ApplicationRecord::OTC_TREE_COMPONENT]
          if num_errors_stack[2] == 0 && ids_stack[2].count > 0
            @upload.status_detail = ApplicationRecord::OTC_TREE_LABELS[ApplicationRecord::OTC_TREE_OUTCOME]
            if num_errors_stack[3] == 0 && ids_stack[3].count > 0
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

  def parseSubCode(str, depth)
    if depth == 0 || depth == 1
      # Area formatting: "AREA #: <name>""
      # Component formatting: "Component #: <name>""
      label = str.split(/:/).first
      return str.gsub(/[^0-9,.]/, "")
    elsif depth == 2
      # Outcome formatting: "Outcome: #. <name>""
      label = str.split(/\./).first
      return label.gsub(/[^0-9,.]/, "")
    elsif depth == 3
      # Indicator formatting: "<area>.<component>.<outcome>.<indicator>. <name>""
      codes = str.split(/ /).first.split(/\./)
      puts "Indicator codes: #{codes.inspect}"
      return codes[3]
    end
  end

  def buildFullCode(codes_stack, depth)
    return codes_stack[0..depth].join('.')
  end

end
