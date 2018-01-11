class UploadsController < ApplicationController

  PROCESSING_DEPTH = 5
  CODE_DEPTH = 4
  ROCESSING_AREA = 0
  ROCESSING_COMPONENT = 1
  ROCESSING_OUTCOME = 2
  ROCESSING_INDICATOR = 3
  ROCESSING_KBE = 4

  # types of stacks
  RECS_STACK = 0
  NUM_ERRORS_STACK = 1
  IDS_STACK = 2
  CODES_STACK = 3


  before_action :authenticate_user!
  before_action :get_locale
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
      @subjectRec = Subject.find(@upload.subject_id)
      @gradeBandRec = GradeBand.find(@upload.grade_band_id)
      @localeRec = Locale.find(@upload.locale_id)
      tree_parent_code = ''
      tree_parent_id = ''
      # to do - refactor this
      case @upload.status
      when BaseRec::UPLOAD_NOT_UPLOADED,
        BaseRec::UPLOAD_TREE_UPLOADING,
        BaseRec::UPLOAD_TREE_UPLOADED

        # to do - get filename from uploads record
        val_filename = 'Hem_09_transl_Eng.csv'

        if upload_params['file'].original_filename == val_filename
          # process file to upload

          # to do - match to final upload layout when determined.
          # map csv headers to short symbols
          long_to_short = Upload.get_long_to_short()
          # stacks is an array whose elements correspond to the depth of the code tree and for
          #  - (e.g. 0 - Area, 1 - Component, 2 - Outcome, ...)
          stacks = Array.new
          stacks[RECS_STACK] = Array.new(CODE_DEPTH) {nil} # current records at each level of procesing
          stacks[NUM_ERRORS_STACK] = Array.new(PROCESSING_DEPTH) {0} # count of errors at each level of procesing
          stacks[IDS_STACK] = Array.new(PROCESSING_DEPTH) {[]} # ids of records at each level of procesing (Areas, ..., sectors, relations)

          CSV.foreach(upload_params['file'].path, headers: true) do |row|
            stacks[CODES_STACK] = Array.new(CODE_DEPTH) {''}
            row_num += 1

            # validate grade band in this row matches this upload
            # do not process this row if it is for the wrong grade level
            grade_band = row[Upload::LONG_HEADERS[4]]
            raise "invalid grade level #{grade_band.inspect} on row: #{row_num}" if grade_band != @gradeBandRec.code

            # process this row
            row.each do |key, val|
              new_key = long_to_short[key]
              # process this column for this row
              case new_key
              when :area
                stacks = process_otc_tree(0, val, row_num, stacks)
              when :component
                stacks = process_otc_tree(1, val, row_num, stacks)
              when :outcome
                stacks = process_otc_tree(2, val, row_num, stacks)
              when :indicator
                stacks = process_otc_tree(3, val, row_num, stacks)
              when :relevantKbe
                process_kbe(val, row_num, stacks)
              end
            end # row.each
          end # CSV.foreach
        else
          flash[:alert] = 'Filename does not match this Upload!'
          abort = true
        end
      when BaseRec::UPLOAD_DONE
        puts("status UPLOAD_DONE, #{BaseRec::UPLOAD_STATUS[BaseRec::UPLOAD_DONE]}")
        abort = true
        @upload = []
      else
        puts("invalid status #{@upload.status}")
        puts("BaseRec::UPLOAD_NOT_UPLOADED: #{BaseRec::UPLOAD_NOT_UPLOADED}")
        puts("BaseRec::UPLOAD_TREE_UPLOADING: #{BaseRec::UPLOAD_TREE_UPLOADING}")
        abort = true
        @upload = []
      end
    end
    if abort
      render :index
    else
      # update status detail message
      if stacks[NUM_ERRORS_STACK][ROCESSING_AREA] == 0 && stacks[IDS_STACK][ROCESSING_AREA].count > 0
        @upload.status = BaseRec::UPLOAD_TREE_UPLOADING
        @upload.status_detail = BaseRec::TREE_LABELS[BaseRec::TREE_AREA]
        if stacks[NUM_ERRORS_STACK][ROCESSING_COMPONENT] == 0 && stacks[IDS_STACK][ROCESSING_COMPONENT].count > 0
          @upload.status_detail = BaseRec::TREE_LABELS[BaseRec::TREE_COMPONENT]
          if stacks[NUM_ERRORS_STACK][ROCESSING_OUTCOME] == 0 && stacks[IDS_STACK][ROCESSING_OUTCOME].count > 0
            @upload.status_detail = BaseRec::TREE_LABELS[BaseRec::TREE_OUTCOME]
            if stacks[NUM_ERRORS_STACK][ROCESSING_INDICATOR] == 0 && stacks[IDS_STACK][ROCESSING_INDICATOR].count > 0
              @upload.status_detail = BaseRec::TREE_LABELS[BaseRec::TREE_INDICATOR]
              @upload.status = BaseRec::UPLOAD_TREE_UPLOADED
              if stacks[NUM_ERRORS_STACK][ROCESSING_KBE] == 0 && stacks[IDS_STACK][ROCESSING_KBE].count > 0
                @upload.status_detail = BaseRec::TREE_LABELS[BaseRec::TREE_INDICATOR]
                @upload.status = BaseRec::UPLOAD_KBE_RELATED
              end
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

  def parseSubCodeText(str, depth)
    if depth == 0 || depth == 1
      # Area formatting: "AREA #: <name>""
      # Component formatting: "Component #: <name>""
      strArray = str.split(/:/)
      label = strArray.first
      text = str[(label.length+1)..-1].lstrip
      return str.gsub(/[^0-9,.]/, ""), text
    elsif depth == 2
      # Outcome formatting: "Outcome: #. <name>""
      strArray = str.split(/\./)
      label = strArray.first
      text = str[(label.length+1)..-1].lstrip
      return label.gsub(/[^0-9,.]/, ""), text
    elsif depth == 3
      # Indicator formatting: "<area>.<component>.<outcome>.<indicator>. <name>""
      strArray = str.split(/ /)
      codes = strArray.first.split(/\./)
      text = str[(strArray.first.length)..-1].lstrip
      return codes[3], text
    end
  end

  def buildFullCode(codes_stack, depth)
    return codes_stack[0..depth].join('.')
  end

  def process_otc_tree(depth, val, row_num, stacks)
    code_str, text = parseSubCodeText(val, depth)
    raise "row number #{row_num}, depth: #{depth} has invalid area code at : #{code_str.inspect}" if code_str.length != 1

    # insert record into tree
    stacks[CODES_STACK][depth] = code_str # save curreant code in codes stack
    new_code, node, save_status, message = Tree.find_or_add_code_in_tree(
      @treeTypeRec,
      @versionRec,
      @subjectRec,
      @gradeBandRec,
      buildFullCode(stacks[CODES_STACK], depth),
      nil, # to do - set parent record for all records below area
      stacks[RECS_STACK][depth]
    )
    if save_status != BaseRec::REC_SKIP

      # update text translation for this locale (if not skipped)
      if save_status == BaseRec::REC_ERROR
        # Note: no update of translation if error
        transl, text_status, text_msg = Translation.find_translation(
          @localeRec.code,
          "#{@treeTypeRec.code}.#{@versionRec.code}.#{@subjectRec.code}.#{@gradeBandRec.code}.#{node.code}.name"
        )
        @errs << message
        stacks[NUM_ERRORS_STACK][depth] += 1
      else # if save_status ...
        # update translation if not an error and value changed
        transl, text_status, text_msg = Translation.find_or_update_translation(
          @localeRec.code,
          "#{@treeTypeRec.code}.#{@versionRec.code}.#{@subjectRec.code}.#{@gradeBandRec.code}.#{node.code}.name",
          text
        )
      end # if save_status ...

      # generate report record if not skipped
      stacks[RECS_STACK][depth] = node
      stacks[IDS_STACK][depth] << node.id if !stacks[IDS_STACK][depth].include?(node.id)
      rptRec = stacks[CODES_STACK].clone # code stack for first four columns of report
      rptRec << new_code
      rptRec << ( transl.value.present? ? transl.value : '' )
      rptRec << "#{BaseRec::SAVE_CODE_STATUS[save_status]} #{BaseRec::SAVE_TEXT_STATUS[text_status]}"
      @rptRecs << rptRec

    end # if not skipped record
    return stacks
  end # process_otc_tree

  def process_kbe(val, row_num, stacks)
    tree_rec = stacks[RECS_STACK][ROCESSING_INDICATOR] # get current indicator record from stacks
    errs = []
    relations = []
    sectorNames = val.present? ? val.split(';') : []
    # get an array of related KBE sectors (note there is an 'All KBE sectors' option)
    sectorNames.each do |s|
      # custom matching of descriptions (that do not correspond with what is in the database)
      if s.upcase.include? 'ALL KBE SECTORS'
        relations = BaseRec::ALL_KBE_SECTORS
        break
      elsif s.upcase.strip == 'IT'
        relations << '1'
      elsif s.upcase.include? 'MEDICINE'
        relations << '2'
      elsif s.upcase.include? 'TECHNOLOGY OF MATERIALS'
        relations << '3'
      elsif s.upcase.include? 'ENERGY'
        relations << '4'
      else
        # not a custom match, get sector code from translation records for sectors.
        matchingSectors = Translation.where('locale = ? AND value LIKE (?)', @localeRec.code, "%#{s.strip}%")
        if matchingSectors.count == 1 # matched description in translation table
          # get the sector record from the kbe code
          kbeCode = matchingSectors.first.key
          sectorCode = Sector.sectorCodeFromKbeCode(kbeCode)
          if BaseRec::ALL_KBE_SECTORS.include?(sectorCode)
            relations << sectorCode
          else
            errs << I18n.translate('app.errors.invalid_kbe_code_for_kbe', code: kbeCode, kbe: s.strip)
          end
        elsif matchingSectors.count == 0
          errs << I18n.translate('app.errors.no_matching_kbe', kbe: s.strip)
        else
          errs << I18n.translate('app.errors.too_many_matched_key', key: s.strip)
        end
      end
    end
    relations.each do |r|
      # get the KBE code from the looked up sector description in the translation table
      begin
        sectors = Sector.where(code: r)
        throw "Missing sector with code #{r.inspect}" if sectors.count < 1
        sector = sectors.first
        # check the sectors_trees table to see if it is joined already
        matchedTrees = sector.trees.where(id: tree_rec.id)
        # if not, join them
        sector.trees.create(id: tree_rec.id) if matchedTrees.count == 0
      rescue ActiveRecord::ActiveRecordError => e
        errs << I18n.translate('app.errors.exception_relating_sector_to_tree', e: e)
      end
    end
    # generate report record
    rptRec = Array.new(CODE_DEPTH) {''} # blank out the first four columns of report
    rptRec << '' # blank out the code column of report
    rptRec << ((relations.count > 0) ? I18n.translate('app.labels.related_to_kbe', kbe: relations.join(', ')) : 'No KBE relations.')
    rptRec << 'Related to KBE '+errs.join(', ')
    @rptRecs << rptRec

  end
end
