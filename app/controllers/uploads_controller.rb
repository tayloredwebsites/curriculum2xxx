class UploadsController < ApplicationController

  PROCESSING_DEPTH = 7
  CODE_DEPTH = 4
  ROCESSING_AREA = 0
  ROCESSING_COMPONENT = 1
  ROCESSING_OUTCOME = 2
  PROCESSING_INDICATOR = 3
  PROCESSING_SECTOR = 4
  PROCESSING_SECTOR_EXPLAIN = 5
  PROCESSING_SUBJECT_REL = 6

  # types of stacks
  RECS_STACK = 0
  NUM_ERRORS_STACK = 1
  IDS_STACK = 2
  CODES_STACK = 3


  before_action :authenticate_user!
  before_action :find_upload, only: [:show, :edit, :update, :start_upload, :do_upload]

  def index
    unauthorized() and return if !user_is_admin?(current_user)
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
    unauthorized() and return if !user_is_admin?(current_user)
    @upload = Upload.new()
  end

  def create
    unauthorized() and return if !user_is_admin?(current_user)
    @upload = Upload.new(upload_params)
    if @upload.save
      flash[:success] = "Upload for #{ @upload.subject.code } #{ @upload.grade_band.code } #{ @upload.locale.name } updated."
      redirect_to uploads_path()
    end
  end

  def show
    unauthorized() and return if !user_is_admin?(current_user)
  end

  def edit
    unauthorized() and return if !user_is_admin?(current_user)
  end

  def update
    unauthorized() and return if !user_is_admin?(current_user)
    if @upload.update(upload_params)
      flash[:notice] = "Upload for #{ @upload.subject.code } #{ @upload.grade_band.code } #{ @upload.locale.name } updated."
      redirect_to uploads_path()
    else
      render :edit
    end
  end

  def upload_summary
    unauthorized() and return if !user_is_admin?(current_user)
    index_prep
  end

  def start_upload
    unauthorized() and return if !user_is_admin?(current_user)
    if @upload
      @message = "Select file to upload to get to next step"
      @errs = []
      @rptRecs = []
      if !@upload.status_detail.present?
        @status_detail = ''
      else
        @status_detail = "<h5>Errors from Phase 1 upload:</h5>#{@upload.status_detail.split('$$$').join('<br>')}"
      end
      if @upload.statusPhase2.present?
        @status_detail += "<br><h5>Errors from Phase 2 upload:</h5>#{@upload.statusPhase2.split('$$$').join('<br>')}"
      end
      Rails.logger.debug("*** @status_detail: #{@status_detail.inspect}")
      render :do_upload
    else
      flash[:notice] = 'Missing upload record.'
      index_prep
      render :index
    end
  end

  def do_upload
    unauthorized() and return if !user_is_admin?(current_user)

    # infomation to send back to user after completion
    row_num = 0
    @message = "Select file to upload to get to next step"
    @errs = []
    @rowErrs = []
    @treeErrs = false
    @sectorErrs = false
    @subjectErrs = false
    @rptRecs = []
    abortRun = false
    @abortRow = false
    @processedCount = 0
    @status_detail = ''

    if @upload && params['upload']
      @subjectRec = @upload.subject
      @gradeBandRec = @upload.grade_band
      @localeRec = @upload.locale
      tree_parent_code = ''

      # check filename
      if upload_params['file'].original_filename != @upload.filename
        flash[:alert] = I18n.translate('uploads.errors.incorrect_filename', filename: @upload.filename)
        abortRun = true
        Rails.logger.debug("*** seed filename: #{@upload.filename.inspect}")
        Rails.logger.debug("*** upload filename: #{upload_params['file'].original_filename.inspect}")
      # elsif @upload.status == BaseRec::UPLOAD_DONE
      #   # skip processing if already done, otherwise process)
      #   Rails.logger.debug("*** file done")
      #   flash[:notify] = I18n.translate('uploads.warnings.already_completed', filename: @upload.filename)
      #   flash[:notify] = "ERROR: "+I18n.translate('uploads.warnings.already_completed', filename: @upload.filename)
      #   abortRun = true
      else
        Rails.logger.debug("*** process file")
        # stacks is an array whose elements correspond to the depth of the code tree (level of processing)
        #  - (e.g. 0 - Area, 1 - Component, 2 - Outcome, ...)
        stacks = Array.new
        stacks[RECS_STACK] = Array.new(CODE_DEPTH) {nil} # current records at each level of procesing
        stacks[NUM_ERRORS_STACK] = Array.new(PROCESSING_DEPTH) {0} # count of errors at each level of procesing
        stacks[IDS_STACK] = Array.new(PROCESSING_DEPTH) {[]} # ids of records at each level of procesing (Areas, ..., sectors, relations)

        grade_band = 0
        stacks[CODES_STACK] = Array.new(CODE_DEPTH) {''}

        File.foreach(upload_params['file'].path).with_index do |line, line_num|
          puts "Process Line #: #{line_num}"
          puts "Process line: #{line}"
          @abortRow = false
          @rowErrs = []
          if line_num == 0
            infoLine = line.split(',')
            begin
              grade_band = @treeTypeRec.code == "egstemuniv" ? infoLine[2].strip : Integer(infoLine[2])
            rescue ArgumentError, TypeError
              grade_band = 0
            end
            puts "grade_band: #{grade_band.inspect}"
            puts "@gradeBandRec.code: #{@gradeBandRec.code.inspect}"
            if grade_band.to_s != @gradeBandRec.code
              puts "Abort (line 158)"
              flash[:alert] = "ERROR: Invalid grade_band: #{grade_band}"
              abortRun = true
              @abortRow = true
            end
            # process header record, so that it creates the grade record in the tree
            # next
            line = "#{grade_band}. #{grade_band}"
          end

          # stacks[CODES_STACK] = Array.new(CODE_DEPTH) {''}

          # split the line at the first space to get the code and description
          codeIn, lineDesc = parseUpTo(line, ' ')
          Rails.logger.debug("code: #{codeIn}, description: #{lineDesc}")
          # split the code into its sub-codes
          codes, codeErr = parseCodeIn(codeIn)
          numCodes, toNumErrors = codesToNums(codes)
          Rails.logger.debug("numCodes: #{numCodes.inspect}")

          # split line into into key: value items (: separating them)
          lineKey, lineValue = parseUpTo(line, ':')
          Rails.logger.debug("lineKey: #{lineKey.inspect}, lineValue: #{lineValue.inspect}")

          # Determine what type of line this is:
          lineType = ''
          Rails.logger.debug("codeErr: #{codeErr}, #{toNumErrors}, #{numCodes.length}")
          if abortRun || @abortRow
            lineType = 'abort'
          elsif codeErr == '' && toNumErrors.length == 0 && numCodes.length > 0
            # We have a standard Unit, Chapter or LO entry line #.#, #.#.#, or #.#.#,#
            Rails.logger.debug("codes: #{codes.inspect} - #{codes.length}")
            case codes.length
            when 1
              lineType = 'Grade'
            when 2
              lineType = 'Unit'
            when 3
              lineType = 'Chapter'
            when 4
              lineType = 'LO'
            else
              lineType = 'Error in code'
            end
          elsif lineValue.length > 0 && lineKey.length < 40
            # we have a key value pair (usually attached to a chapter)
            # e.g. Key Concepts: nutrition, biology, ...
            lineType = 'Keyed Description'
          elsif codeErr == '' && toNumErrors != '' && numCodes.length == 1
            # we have a standard indicator (letter followed by .)
            lineType = 'Indicator'
          else
            lineType = 'Error parsing line'
          end
          Rails.logger.debug("lineType: #{lineType}")


          Rails.logger.debug("codes: #{codes.inspect}, codeErr: #{codeErr}")
          @rowErrs << codeErr if codeErr && codeErr != ''
          Rails.logger.debug("@rowErrs: #{@rowErrs.inspect}")

          case lineType
          when 'Grade'
            # Grade entry
            Rails.logger.debug("toNumErrors: #{toNumErrors.inspect}")
            @rowErrs << toNumErrors if toNumErrors && toNumErrors.length > 0
            @rowErrs << "grade mismatch: #{grade_band.inspect} != #{numCodes[0].inspect}" if grade_band != numCodes[0]
            stacks[CODES_STACK] = [ numCodes[0] ]
            processTfvTree(line_num, numCodes, 1, lineDesc)
          when 'Unit'
            # Unit entry
            Rails.logger.debug("toNumErrors: #{toNumErrors.inspect}")
            @rowErrs << toNumErrors if toNumErrors && toNumErrors.length > 0
            @rowErrs << "grade mismatch: #{grade_band.inspect} != #{numCodes[0].inspect}" if grade_band != numCodes[0]
            if stacks[CODES_STACK][0] == numCodes[0]
              Rails.logger.debug("*** Unit matched prior record codes #{stacks[CODES_STACK][0].inspect}")
              stacks[CODES_STACK] = [ numCodes[0], numCodes[1] ]
            else
              Rails.logger.debug("ERROR: Unit MISMATCH prior record codes #{stacks[CODES_STACK][0].inspect} != #{numCodes[0].inspect}")
              @rowErrs << "Unit MISMATCH prior record codes"
              @abortRow = true
            end
            processTfvTree(line_num, numCodes, 1, lineDesc)

          when 'Chapter'
            # Chapter entry
            numCodes, toNumErrors = codesToNums(codes)
            Rails.logger.debug("toNumErrors: #{toNumErrors.inspect}")
            @rowErrs << toNumErrors if toNumErrors && toNumErrors.length > 0
            @rowErrs << "grade mismatch: #{grade_band.inspect} != #{numCodes[0].inspect}" if grade_band != numCodes[0]
            if stacks[CODES_STACK][0..1] == [ numCodes[0], numCodes[1] ]
              Rails.logger.debug("*** Chapter matched prior record codes #{stacks[CODES_STACK].inspect}")
              stacks[CODES_STACK] = [ numCodes[0], numCodes[1], numCodes[2] ]
            else
              Rails.logger.debug("ERROR: Chapter MISMATCH prior record codes #{stacks[CODES_STACK].inspect}")
              @rowErrs << "Chapter MISMATCH prior record codes"
              @abortRow = true
            end
            processTfvTree(line_num, numCodes, 2, lineDesc)

          when 'LO'
            # Outcome entry
            numCodes, toNumErrors = codesToNums(codes)
            Rails.logger.debug("toNumErrors: #{toNumErrors.inspect}")
            @rowErrs << toNumErrors if toNumErrors && toNumErrors.length > 0
            @rowErrs << "grade mismatch: #{grade_band.inspect} != #{numCodes[0].inspect}" if grade_band != numCodes[0]
            if stacks[CODES_STACK][0..2] == [ numCodes[0], numCodes[1], numCodes[2] ]
              Rails.logger.debug("*** LO matched prior record codes #{stacks[CODES_STACK].inspect}")
              stacks[CODES_STACK] = [ numCodes[0], numCodes[1], numCodes[2], numCodes[3] ]
            else
              Rails.logger.debug("ERROR: LO MISMATCH prior record codes #{stacks[CODES_STACK].inspect}")
              @rowErrs << "LO MISMATCH prior record codes"
              @abortRow = true
            end
            processTfvTree(line_num, numCodes, 3, lineDesc)

          when 'Keyed Description'
            # indicator (with a letter) - note it is passed without code hierarchy
            # note: top item in displayed code is grade number, so is ignored in hierarchy
            Rails.logger.debug("Keyed Description - #{lineKey}: #{lineValue}")

          when 'Indicator'
            # indicator (with a letter) - note it is passed without code hierarchy
            # note: top item in displayed code is grade number, so is ignored in hierarchy
            Rails.logger.debug("Indicator: #{codes.join('.')}, #{lineDesc}")
            indCodes = stacks[CODES_STACK].dup
            indCodes.concat(codes)
            processTfvTree(line_num, indCodes, 4, lineDesc)
          else
            abort "just developing for now"
          end

          break if abortRun || @abortRow || @rowErrs.count > 0
          @errs.concat(@rowErrs)
        end # File.foreach
      end # check filename and then process file
    else
      Rails.logger.error("ERROR:  invalid params: #{params}")
      flash[:alert] = "ERROR: MISSING upload filename"
      abortRun = true
    end # if upload
    if abortRun
      Rails.logger.error("ERROR:  abort run: #{flash[:alert]}")
      index_prep
      render :index
    else
      # Update status level
      Rails.logger.debug("*** Update Status Level.")
      if  @processedCount > 0
        @upload.status = BaseRec::UPLOAD_TREE_UPLOADING
        Rails.logger.debug("tree errors: #{@treeErrs.inspect}")
        if !@treeErrs
          Rails.logger.debug("no tree errors")
          @upload.status = BaseRec::UPLOAD_TREE_UPLOADED
        end
      # save all errors into the upload status detail field for easy review of last run of errors
        @upload.status_detail = @errs.join('$$$')
        @upload.status = BaseRec::UPLOAD_DONE if @upload.status == BaseRec::UPLOAD_TREE_UPLOADED
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
    params.require('upload').permit(:subject_id, :grade_band_id, :locale_id, :status, :file, :phase, :upload)
    # # ToDo - what is the upload param for ???
    # # params.permit(:subject_id, :grade_band_id, :locale_id, :status, :file, :phase, :upload)
    # params.permit(:utf8, :authenticity_token, :upload, :locale, :id, :phase)
  end

  def index_prep
    @uploads = Upload.order(:id).includes([:subject, :grade_band, :locale]).all.upload_listing
  end


  def processTfvTree(line_num, numCodes, depth, localText)

    # update text translation for this locale (if not skipped)
    if !@abortRow
      # insert record into tree
      max_seq = Tree.where(:subject_id=> @subjectRec.id).pluck(:sequence_order).max()
      sequence_order = (max_seq) ? 1 + max_seq : 1
      new_seq = depth == 3 ? sequence_order : 0
      new_code, @rowTreeRec, save_status, message = Tree.find_or_add_code_in_tree(
        @treeTypeRec,
        @versionRec,
        @subjectRec,
        @gradeBandRec,
        numCodes.join('.'),
        depth,
        line_num,
        new_seq
      )
      if save_status == BaseRec::REC_ERROR
        @rowErrs << message if message.present?
        # stacks[NUM_ERRORS_STACK][depth] += 1
        # Note: no update of translation if error
        translation_val = ''
      else # if save_status not error
        @processedCount += 1
        # update translation if not an error and value changed
        puts("find or update translation: #{@localeRec.code}, #{@rowTreeRec.base_key}#{numCodes.join('.')}.name, #{localText}")
        transl, text_status, text_msg = Translation.find_or_update_translation(
          @localeRec.code,
          "#{@rowTreeRec.base_key}.name",
          localText
        )
        if text_status == BaseRec::REC_ERROR
          @rowErrs << text_msg
        end
        translation_val = transl.value.present? ? transl.value : ''
      end # if save_status ...

      statMsg = I18n.translate('uploads.labels.saved_code', code: numCodes.join('.')) if save_status == BaseRec::REC_ADDED ||save_status == BaseRec::REC_UPDATED

    end # if !@abortRow

    statMsg = statMsg.blank? ? "#{@rowErrs.join(', ')}" : statMsg + ", #{@rowErrs.join(', ')}" if @rowErrs.count > 0

    # generate report record if not skipped
    rptRec = [line_num]
    rptRec.concat(numCodes.concat(['','','','']).slice(0,5))  # first five columns are codes or blanks
    rptRec << new_code
    rptRec << translation_val
    rptRec << statMsg
    Rails.logger.debug("+++ final rptRec: #{rptRec.inspect}")
    @rptRecs << rptRec

  end


  # Parse the 'string' up to the first instance of character 'char'
  # Returns an array with:
  #  - everything up to the first instance of character 'char'
  #  - everything after the first instance of character 'char'
  def parseUpTo(string, char)
    posit = string.index(char)
    if posit
      return string.slice(0,posit),
        string.slice(posit+1, string.length-posit-1)
    else
      return string, ''
    end
  end

  # Parse the codeIn string (split by .).
  # returns array of codes
  def parseCodeIn(codeIn)
    codes = codeIn.split('.') # add ', 999' to limit to return all trailing empty fields
    Rails.logger.debug("codes: #{codes.inspect}")
    # removes ) at end of any indicator codes
    if codes.length == 1 && codes[0].length > 1
      if codes[0][1] == ')'
        codes[0] = codes[0][0]
      elsif codes[0][2] == ')'
        codes[0] = codes[0][0] + codes[0][1]
      elsif codes[0][3] == ')'
        codes[0] = codes[0][0] + codes[0][1] + codes[0][2]
      end
      Rails.logger.debug("updated codes: #{codes.inspect}")
    end
    # error = (codes[codes.length-1] != '') ? 'Invalid code - no trailing .' : ''
    error = ''
    # sbNullStr = codes.pop(1)
    return codes, error
  end

  def codesToNums(codes)
    numCodes = []
    errors = []
    codes.each_with_index do |code, ix|
      begin
        numCode = @treeTypeRec.code == "egstemuniv" ? code : Integer(code)
        numCodes << numCode
      rescue
        numCodes << -1
        errors << "invalid code at: #{ix} with value: #{code}"
      end
    end
    return numCodes, errors
  end


end
