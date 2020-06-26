class UploadsController < ApplicationController

  require 'csv'

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
  before_action :build_resource_names, only: [:do_upload]

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
    @upload = Upload.new(
        status: 0,
      )
    @errs = []
    @message = "Select file to upload to get to next step"
    @rptRecs = []
    render :do_upload
  end

  def create
    unauthorized() and return if !user_is_admin?(current_user)
    @upload = Upload.new(upload_params)
    if @upload.save
      flash[:success] = "Upload for #{ @upload.subject.code } #{ @upload.locale.name } updated."
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
      # @gradeBandRec = @upload.grade_band
      @gradeBandRec = GradeBand.new
      @localeRec = @upload.locale
      tree_parent_code = ''

      # check filename (allow for capitalization differences)
      if upload_params['file'].original_filename.downcase != @upload.filename.downcase
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

        filePath = upload_params['file'].path

        fileExt = @upload.filename.split('.')[1]
        if fileExt == 'csv'
          v2FileUpload(filePath, '#')
        else
          v1FileUpload(filePath, separator)
        end
        abortRun = true if @abortRun
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
        updateSubjectGrades(@subjectRec)
      end
      render :do_upload
    end
  end


  private

  def v2FileUpload(filePath, separator)
    # if @treeTypeRec.hierarchy_codes != "grade,unit,sub_unit,comp"
    #   @abortRun = abortWithMessage("ERROR - cannot upload this format tree hierarchy yet. #{@treeTypeRec.hierarchy_codes}")
    # end
    # if @treeTypeRec.tree_code_format != "subject,grade,unit,sub_unit,comp"
    #   @abortRun = abortWithMessage("ERROR - cannot upload this format tree code yet. #{@treeTypeRec.tree_code_format}")
    # end

    @rowNum = 2
    @recordOrder = 0
    @baseKeyRoot = "#{@treeTypeRec.code}.#{@versionRec.code}.#{@subjectRec.code}"
    @sectorArrByKeyPhrase = []
    Sector.where(
      # Use TreeType::get_sector_set_code(code) to separate sector_set_code from 'hidden' flag
      sector_set_code: TreeType.get_sector_set_code(@treeTypeRec.sector_set_code)
    ).each { |s| @sectorArrByKeyPhrase << [s.key_phrase, s] if s.key_phrase != "" }
    # hash of the existing records for this TreeType (curriculum) and subject
    #
    @currentRecs = Hash.new{ |h, k| h[k] = {} }
    currentCodeRecs = Tree.active.where(tree_type_id: @treeTypeRec.id, version_id: @versionRec.id, subject_id: @subjectRec.id)
    currentCodeRecs.each do |rec|
      transl_names = Translation.where(locale: @locale_code, key: "#{rec.base_key}.name")
      if transl_names.count > 0
        transl_name = transl_names.first.value
        transl_id = transl_names.first.id
      else
        transl_name = ''
        transl_id = nil
      end
      @currentRecs[rec.code] = {updated: false, rec: rec, transl_name: transl_name, transl_id: transl_id}
      Rails.logger.debug("*** Initial currentRec: #{rec.inspect}")

    end

    #   - Create a hash (at beginning of upload process) of the Dimensions for this subject, and dimension type (not by Tree Type - to prevent dups)
    @currentDims = Hash.new{ |h, k| h[k] = Hash.new{ |h, k| h[k] = {} } }
    currentDims = Dimension.where(subject_code: @subjectRec.code, active: true)
    currentDims.each do |rec|
      transl_names = Translation.where(locale: @locale_code, key: rec.get_dim_name_key)
      if transl_names.count > 0
        transl_name = transl_names.first.value
        transl_id = transl_names.first.id
      else
        transl_name = ''
        transl_id = nil
      end
      if transl_name.present?
        @currentDims[rec.dim_type][transl_name] = {updated: false, rec: rec, transl_name: transl_name, transl_id: transl_id}
      else
        # Ignoring this condition for now
      end
    end

    # Dimension names used in dimension upload reporting
    bigideaDimTypeName = Dimension.get_dim_type_name('bigidea', @treeTypeRec.code, @versionRec.code, @locale_code)
    essqDimTypeName = Dimension.get_dim_type_name('essq', @treeTypeRec.code, @versionRec.code, @locale_code)
    conceptsDimTypeName = Dimension.get_dim_type_name('concept', @treeTypeRec.code, @versionRec.code, @locale_code)
    skillDimTypeName = Dimension.get_dim_type_name('skill', @treeTypeRec.code, @versionRec.code, @locale_code)
    misconDimTypeName = Dimension.get_dim_type_name('miscon', @treeTypeRec.code, @versionRec.code, @locale_code)
    practDimTypeName = Dimension.get_dim_type_name('pract', @treeTypeRec.code, @versionRec.code, @locale_code)


    # hash to hold the last code used (we are incrementing codes and saving the last in the parent key)
    # hash also holds the last set of values assigned a code, so we get the proper code for previous records.
    # structure of hash = parentCode: { lastSubCode: code ,valuesAssigned: { name: code } }
    @lastSubCode = Hash.new{ |h, k| h[k] = {} }

    CSV.open(filePath, {headers: true, col_sep: separator}).each_with_index do |row, iy|

      # To Do: make sure that all upload file column headers are correct and accounted for:
      #   - mispellings will cause missing values from the CSV row hash
      #   - maybe pre-read row 1 and confirm the column headers.  Sequence and similarity may help with this.
      #      - try: firstRow = File.open(filePath, &:readline)

      break if @abortRun

      Rails.logger.debug("")
      Rails.logger.debug("##########################################################")
      Rails.logger.debug("### row iy: #{iy}, @rowNum: #{@rowNum}")
      rowH = row.to_hash.with_indifferent_access
      Rails.logger.debug("### tree type rec: #{@treeTypeRec.inspect}")
      Rails.logger.debug("### tree code format: #{@treeTypeRec.tree_code_format}")

      isValidRow = checkRecord(rowH)

      ttRecArray = @treeTypeRec.tree_code_format.split(',')
      ttRecArray.each_with_index do |ix|

      end

      if isValidRow == 'valid'

        # confirm we have a valid grade before starting
        @gradeCodeIn = rowH['Grade'] || rowH['Proposed Grade']
        @gradeCode = minTwoDigCode(@gradeCodeIn, ' ', '')
        Rails.logger.debug("### @gradeCodeIn: #{@gradeCodeIn}, @gradeCode: #{@gradeCode}")
        Rails.logger.debug("### @treeTypeRec.id: #{@treeTypeRec.id}")
        @gradeBandRec = GradeBand.where(tree_type_id: @treeTypeRec.id, code: noLeadingZeros(@gradeCode)).first
        @abortRun = abortWithMessage("ERROR - missing grade band: #{@gradeCode}") if !@gradeBandRec
        break if @abortRun

        Rails.logger.debug("### @gradeBandRec: #{@gradeBandRec.inspect}")
        Rails.logger.debug("### Proposed Grade: #{@gradeCode} - found '#{@gradeBandRec.code}'")

        # process the record in hierarchy order
        hierarchyCodeArray = [] # the array that gets built with the record codes in hierarchy order


        ################################################################
        # Create the Hierarchy Tree records for this row
        @treeTypeRec.hierarchy_codes.split(',').each_with_index do |hCode, ix|
          Rails.logger.debug("*** Hierarchy was: #{hierarchyCodeArray.join(',')}, code at: #{ix} = #{hCode}")

          colSemesterCode = rowH['Semester']
          colUnitName = rowH['Unit'] || rowH['Unit Name']
          colSubUnitName = rowH[' Sub unit']
          colFullLoCode = rowH['LO Code:']
          colLoDesc = rowH['Learning Outcome'] || rowH['Proposed Student Competences']
          if hCode == 'grade' && @gradeCode
            Rails.logger.debug("*** Process Grade field: #{hierarchyCodeArray.join('.')} - #{@gradeCode}")
            # use the grade number as the code
            gradeCode = lookupItemCodeForName(@gradeCode, hierarchyCodeArray.join('.'))
            hierarchyCodeArray = processField(hierarchyCodeArray, @gradeCode, @gradeCode, ix, rowH)
          elsif hCode == 'sem' && colSemesterCode
            # if semester code is numeric, use that for the code
            minCode = minTwoDigCode(colSemesterCode, ' ', '')
            Rails.logger.debug("*** minCode: #{minCode}")
            semCode = lookupItemCodeForName(minCode, hierarchyCodeArray.join('.'))
            Rails.logger.debug("*** semCode: #{semCode}")
            hierarchyCodeArray = processField(hierarchyCodeArray, semCode, semCode, ix, rowH)
            Rails.logger.debug("*** Process Semester field: #{hierarchyCodeArray.join('.')} - #{colSemesterCode}")
          elsif hCode == 'unit' && colUnitName
            # get a code for the unit name (assigned sequentially as found)
            Rails.logger.debug("*** Process Unit field: #{hierarchyCodeArray.join('.')} - #{colUnitName}")
            minCode = minTwoDigCode(colUnitName, ' ', '')
            unitCode = lookupItemCodeForName(minCode, hierarchyCodeArray.join('.'))
            hierarchyCodeArray = processField(hierarchyCodeArray, unitCode, colUnitName, ix, rowH)
          elsif hCode == 'subunit' #  if no sub_unit value passed in, write a special record to allow attaching competencies below it
            # get a code for the sub-unit name, if given (assigned sequentially as found)
            # optional records look like: <code: "<grade>.<unit>.", name_key: nil, base_key: "">
            Rails.logger.debug("*** Process Sub Unit field: #{hierarchyCodeArray.join('.')} - #{colSubUnitName}")
            minCode = minTwoDigCode(colSubUnitName, ' ', '')
            subUnitCode = lookupItemCodeForName(minCode, hierarchyCodeArray.join('.'))
            hierarchyCodeArray = processField(hierarchyCodeArray, subUnitCode, colSubUnitName, ix, rowH)
          elsif (hCode == 'lo' || hCode == 'comp') && colLoDesc
            Rails.logger.debug("*** colLoDesc: #{colLoDesc}, colLoDesc: #{colLoDesc}, colFullLoCode: #{colFullLoCode}")
            if colFullLoCode.present?
              # If given the Full LO Code, get the code number by splitting the LO Code by periods, getting the last one, and only keeping the digits
              colLoCode = minTwoDigCode(colFullLoCode.split('.').last.delete('^0-9'), '', '')
            else
              colLoCode = lookupItemCodeForName(minTwoDigCode(colLoDesc, ' ', ''), hierarchyCodeArray.join('.'))
            end
            Rails.logger.debug("*** colLoCode: #{colLoCode}")
            hierarchyCodeArray = processField(hierarchyCodeArray, colLoCode, colLoDesc, ix, rowH)
            Rails.logger.debug("*** To Do - Process LO field: #{hierarchyCodeArray.join('.')} - #{colLoDesc}")
          else
            Rails.logger.debug("*** skip this code")
          end
        end # hierarchy_codes each_with_index

        # save the code array for the Learning Outcome tree record.
        loCodeArray = hierarchyCodeArray.clone()
        loCodeString = loCodeArray.join('.')
        Rails.logger.debug("*** loCodeArray: #{loCodeArray.inspect}, loCodeString: #{loCodeString}")


        ################################################################
        # Process all fields to go into the Learning Outcome record, then add/map/update as needed

        priorLoTreeRecH = @currentRecs[loCodeString]
        currentLoTreeRec = priorLoTreeRecH[:rec]
        currentOutcomeId = currentLoTreeRec.outcome_id
        outcomeBaseKey = @baseKeyRoot + '.' + loCodeString + '.outc'
        Rails.logger.debug("*** currentLoTreeRec.id: #{currentLoTreeRec.id}, currentOutcomeId: #{currentOutcomeId}, outcomeBaseKey: #{outcomeBaseKey}")
        if currentOutcomeId.present?
          # load in existing Outcome record
          outRec = Outcome.find(currentOutcomeId)
        else
          # create new Outcome record
          outRec = Outcome.create(base_key: outcomeBaseKey)
        end

        # If LO code supplied, use it as the display of the full lo code (if supplied)
        ## To Do : add displayLoCode field to Outcome record
        colLoFullCode = rowH['LO Code:']

        # create the duration_weeks field in the LO Record
        startWeekStr = rowH['Start Week']
        endWeekStr = rowH['End Week']
        startWeekNum = endWeekNum = 0
        durationWeeks = 0
        if startWeekStr.present? && endWeekStr.present?
          startWeekNum = Integer(startWeekStr.delete('^0-9')) rescue 0
          endWeekNum = Integer(endWeekStr.delete('^0-9')) rescue 0
        end
        if startWeekNum != 0 && endWeekNum != 0 && endWeekNum >= startWeekNum
          durationWeeks = endWeekNum - startWeekNum + 1
        end
        Rails.logger.debug("+++ durationWeeks: #{durationWeeks}")
        Rails.logger.debug("+++ outRec.duration_weeks: #{outRec.duration_weeks}")
        # update duration weeks
        if outRec.duration_weeks != durationWeeks
          Rails.logger.debug("+++ Update outcome")
          outRec.update(duration_weeks: durationWeeks)
          @rptRecs << [@rowNum.to_s,'','','','',''].concat([loCodeString, "Duration Weeks", "Updated"])
          @recordOrder += 1
        end


        # class_text resource field to store the Textbook Materials and Resources field
        classTextValue = rowH['Textbook Materials and Resources']
        Rails.logger.debug("*** classTextValue: #{classTextValue}")
        if classTextValue.present?
          Rails.logger.debug("*** classTextValue is present: #{classTextValue}")
          transl, text_status, text_msg = Translation.find_or_update_translation(
            @localeRec.code,
            outRec.get_resource_key('class_text'),
            classTextValue
          )
          if text_status == BaseRec::REC_ERROR
            @rowErrs << text_msg
            rptMessage = "ERROR: #{text_msg}"
          elsif text_status == BaseRec::REC_ADDED
            rptMessage = "Added"
          elsif text_status == BaseRec::REC_NO_CHANGE
            rptMessage = ""
          else
            rptMessage = "Updated"
          end
          Rails.logger.debug("*** rptMessage: #{rptMessage}")
          if rptMessage.present?
            @rptRecs << [@rowNum.to_s,'','','','',''].concat([
              loCodeString,
              "Textbook Materials and Resources: #{classTextValue}",
              rptMessage]
            )
            @recordOrder += 1
          end
        end

        # evidence_of_learning field to store the Evidence of Learning field
        evidLearningValue = rowH['Evidence of Learning']
        Rails.logger.debug("*** evidLearningValue: #{evidLearningValue}")
        if evidLearningValue.present?
          Rails.logger.debug("*** evidLearningValue exists: #{evidLearningValue}")
          Translation.find_or_update_translation(@localeRec.code, outRec.get_evidence_of_learning_key, evidLearningValue)
          transl, text_status, text_msg = Translation.find_or_update_translation(
            @localeRec.code,
            outRec.get_evidence_of_learning_key,
            evidLearningValue
          )
          if text_status == BaseRec::REC_ERROR
            @rowErrs << text_msg
            rptMessage = "ERROR: #{text_msg}"
          elsif text_status == BaseRec::REC_ADDED
            rptMessage = "Added"
          elsif text_status == BaseRec::REC_NO_CHANGE
            rptMessage = ""
          else
            rptMessage = "Updated"
          end
          Rails.logger.debug("*** rptMessage: #{rptMessage}")
          if rptMessage.present?
            @rptRecs << [@rowNum.to_s,'','','','',''].concat([
              loCodeString,
              "Evidence of Learning: #{evidLearningValue}",
              rptMessage]
            )
            @recordOrder += 1
          end
        end

        # To Do: standardize and refactor this
        # "Teacher Support" is currently hard coded to the "Explanatory Comments" upload field
        explCommentsValue = rowH['Explanatory Comments']
        Rails.logger.debug("*** explCommentsValue: #{explCommentsValue}")
        if explCommentsValue.present?
          Rails.logger.debug("*** explCommentsValue exists: #{explCommentsValue}")
          transl, text_status, text_msg = Translation.find_or_update_translation(
            @localeRec.code,
            outRec.get_explain_key,
            explCommentsValue
          )
          if text_status == BaseRec::REC_ERROR
            @rowErrs << text_msg
            rptMessage = "ERROR: #{text_msg}"
          elsif text_status == BaseRec::REC_ADDED
            rptMessage = "Added"
          elsif text_status == BaseRec::REC_NO_CHANGE
            rptMessage = ""
          else
            rptMessage = "Updated"
          end
          Rails.logger.debug("*** rptMessage: #{rptMessage}")
          if rptMessage.present?
            @rptRecs << [@rowNum.to_s,'','','','',''].concat([
              loCodeString,
              "Explanatory Comments: #{explCommentsValue}",
              rptMessage]
            )
            @recordOrder += 1
          end
        end



        ################################################################
        # Create the Dimension records and map it to the Learning Outcome.
        @treeTypeRec.dim_codes.split(',').each_with_index do |dCode, ix|
          'bigidea,essq,concept,skill,miscon,pract'
          Rails.logger.debug("*** dimension code at: #{ix} = #{dCode}")
          colBigIdea = rowH['Big Idea'] || rowH['Specific big idea']
          colEssq = rowH['Essential Questions'] || rowH['K-12 Big Idea ']
          colConcepts = rowH['Concepts']
          colSkills = rowH['Skills']
          colMiscon = nil # rowH['No Misconceptions Column']
          colPractice = rowH['Associated Practices']
          colUsStandard = rowH['US Standard']
          colEgStandard = rowH['Egyptian Standard']

          currentRec = @currentRecs[loCodeString] # tree rec for the learning outcome / competency

          if dCode == 'bigidea' && colBigIdea
            createdOrUpdated = createOrUpdateDimRecs(currentRec, @subjectRec.id, 'bigidea', 0, 12, @subjectRec.code, colBigIdea, 'From Upload', rowH)
            @rptRecs << [@rowNum.to_s,'','','','',''].concat([loCodeString, "#{bigideaDimTypeName}: #{colBigIdea}", createdOrUpdated]) if createdOrUpdated.present?
          elsif dCode == 'essq' && colEssq
            createdOrUpdated = createOrUpdateDimRecs(currentRec, @subjectRec.id, 'essq', 0, 12, @subjectRec.code, colEssq, 'From Upload', rowH)
            @rptRecs << [@rowNum.to_s,'','','','',''].concat([loCodeString, "#{essqDimTypeName}: #{colEssq}", createdOrUpdated]) if createdOrUpdated.present?
          elsif dCode == 'concept' && colConcepts
            createdOrUpdated = createOrUpdateDimRecs(currentRec, @subjectRec.id, 'concept', 0, 12, @subjectRec.code, colConcepts, 'From Upload', rowH)
            @rptRecs << [@rowNum.to_s,'','','','',''].concat([loCodeString, "#{conceptsDimTypeName}: #{colConcepts}", createdOrUpdated]) if createdOrUpdated.present?
          elsif dCode == 'skill' && colSkills
            createdOrUpdated = createOrUpdateDimRecs(currentRec, @subjectRec.id, 'skill', 0, 12, @subjectRec.code, colSkills, 'From Upload', rowH)
            @rptRecs << [@rowNum.to_s,'','','','',''].concat([loCodeString, "#{skillDimTypeName}: #{colSkills}", createdOrUpdated]) if createdOrUpdated.present?
          elsif dCode == 'miscon' && colMiscon
            createdOrUpdated = createOrUpdateDimRecs(currentRec, @subjectRec.id, 'miscon', 0, 12, @subjectRec.code, colMiscon, 'From Upload', rowH)
            @rptRecs << [@rowNum.to_s,'','','','',''].concat([loCodeString, "#{misconDimTypeName}: #{colMiscon}", createdOrUpdated]) if createdOrUpdated.present?
          elsif dCode == 'pract' && colPractice
            createdOrUpdated = createOrUpdateDimRecs(currentRec, @subjectRec.id, 'pract', 0, 12, @subjectRec.code, colPractice, 'From Upload', rowH)
            @rptRecs << [@rowNum.to_s,'','','','',''].concat([loCodeString, "#{practDimTypeName}: #{colPractice}", createdOrUpdated]) if createdOrUpdated.present?
          elsif dCode == 'standardus' && colUsStandard
            createdOrUpdated = createOrUpdateDimRecs(currentRec, @subjectRec.id, 'standardus', 0, 12, @subjectRec.code, colUsStandard, 'From Upload', rowH)
            @rptRecs << [@rowNum.to_s,'','','','',''].concat([loCodeString, "#{practDimTypeName}: #{colUsStandard}", createdOrUpdated]) if createdOrUpdated.present?
          elsif dCode == 'standardeg' && colEgStandard
            createdOrUpdated = createOrUpdateDimRecs(currentRec, @subjectRec.id, 'standardeg', 0, 12, @subjectRec.code, colEgStandard, 'From Upload', rowH)
            @rptRecs << [@rowNum.to_s,'','','','',''].concat([loCodeString, "#{practDimTypeName}: #{colEgStandard}", createdOrUpdated]) if createdOrUpdated.present?
          else
            Rails.logger.debug("*** skip the '#{dCode}' dimension")
          end

        end  # dim_codes each_with_index

        @processedCount += 1

      elsif isValidRow == 'blank'
        # # skip this record
      elsif isValidRow == 'dimensions'
        # Dimensions/Dimension Resources only
        # Use @dimsArray from application controller
        # @dimsArray << {code: dim_code, name: dim_name}
        @dimsArray.each do |dimH|
          dim_name = dimH[:name]
          dim_code = dimH[:code]
          dim_text = rowH[dim_name]
          default_grades = {:min => GradeBand::MIN_GRADE, :max => GradeBand::MAX_GRADE}
          grades = rowH['Grade band'].present? ? parseGrades(rowH['Grade band']) : default_grades
          if dim_text.present?
            createdOrUpdated = createOrUpdateDimRecs(
              nil,
              @subjectRec.id,
              dim_code,
              grades[:min],
              grades[:max],
              @subjectRec.code,
              dim_text,
              'From Upload',
              rowH
            )
            @rptRecs << [@rowNum.to_s,'','','','',''].concat(["", "#{dim_name}: #{dim_text}", createdOrUpdated]) if createdOrUpdated.present?
          end
        end
      else
        # build a report with an error
        rptRec = [@rowNum.to_s]
        rptRec.concat(['','','','','']) # get exactly 5 codes to output
        rptRec.concat(['', '', "Missing required fields"])
        Rails.logger.debug("+++ final rptRec: #{rptRec.inspect}")
        @rptRecs << rptRec

      end


      # Rails.logger.debug("### Explanatory Comments: #{rowH['Explanatory Comments']}")
      # Rails.logger.debug("### Misconceptions: #{rowH['Misconceptions']}")
      # Rails.logger.debug("### Display relations: #{rowH['Display relations']}")
      # Rails.logger.debug("### Resourcs: #{rowH['Resourcs']}")

      @rowNum += 1
      break if @abortRun
    end

    # To Do: remove records in @currentRecs that were not updated.
    #    Otherwise, old uploads for this curriculum/subject will remain.

    @rptRecs << ['','','','','','','','','End of Report']
  end

  def processField(parentCodeArray, code, codeName, ix, rowH)
    ######################################################
    # Write the Grade level tree record (create or update)
    hierarchyCodeArray = parentCodeArray.clone()
    hierarchyCodeArray << code
    Rails.logger.debug("*** parentCodeArray: #{parentCodeArray.inspect}, code: #{code}")
    Rails.logger.debug("*** hierarchyCodeArray: #{hierarchyCodeArray.inspect}")
    currentRec = @currentRecs[hierarchyCodeArray.join('.')]
    Rails.logger.debug("*** currentRec: #{currentRec.inspect}")
    rptRec = writeTreeRecord(ix, parentCodeArray, hierarchyCodeArray, code, codeName, currentRec, '', rowH)
    @rptRecs <<  rptRec if rptRec.present?
    @recordOrder += 1

    # refactor this, so it is only run at the end of the upload
    @subjectRec.update(min_grade: @gradeBandRec.min_grade) if @subjectRec.min_grade > @gradeBandRec.min_grade
    @subjectRec.update(max_grade: @gradeBandRec.max_grade) if @subjectRec.max_grade < @gradeBandRec.max_grade
    return hierarchyCodeArray
  end

  # Create code with minimum 2 digits, numeric leading zero, string specify leading or trailing fill
  def minTwoDigCode(strCodeIn, ifStrLead, ifStrTrail)
    if strCodeIn.blank?
      # return empty string if nil, etc.
      retCode = ""
    elsif strCodeIn.length == 1
      if strCodeIn.delete('^0-9') == strCodeIn
        strCodeNum = Integer(strCodeIn) rescue 0
        retCode = format('%02d', strCodeNum)
      else
        retCode = ifStrLead+strCodeIn+ifStrTrail
      end
    else
      retCode = strCodeIn
    end
  end

  def noLeadingZeros(strCodeIn)
    return strCodeIn.gsub(/\b0+(?=\d)/,'')
  end

  def lookupItemCodeForName(itemName, parentCode)
    # determine code from codeName field.
    # check hash for parent, seeing last used, and the hash to get the code from the codeName(key)
    # if blank codeName, then should be optional subUnit, so return empty string.
    # if no children written yet for code, then set it to 1
    # if a child has a matching codeName, then use that code
    # otherwise increment the code last used.
    lastCodeH = @lastSubCode[parentCode]
    Rails.logger.debug("+++ parentCode: #{parentCode}, lastCodeH: #{lastCodeH.inspect}")
    if itemName.blank?
      itemCode = ''
    elsif lastCodeH.present?
      Rails.logger.debug("+++ lastCodeH[:valuesAssigned][#{itemName}]: #{lastCodeH[:valuesAssigned][itemName]}")
      lookupItem = lastCodeH[:valuesAssigned][itemName]
      if lookupItem.present?
        Rails.logger.debug("+++ set code to matched value (lookupItem.present?)")
        # found matching code text, use that code (as an integer)
        lastCode = Integer(lookupItem) rescue 0
      else
        # no matching code text, increment from the last code used for this parent.
        Rails.logger.debug("+++ set code to increment last grade's value: #{lastCodeH[:lastSubCode].inspect}")
        lastCode = Integer(lastCodeH[:lastSubCode]) rescue 0
        lastCode += 1
      end
      itemCode = minTwoDigCode(lastCode.to_s, '', '')
    else
      # no units have been assigned yet
      Rails.logger.debug("+++ set code to 01")
      lastCode = 1
      itemCode = '01'
    end
    return itemCode
  end

  def abortWithMessage(msg)
    Rails.logger.error(msg)
    flash[:alert] = msg
    return @abortRun = true
  end

  def checkRecord(rowH)
    Rails.logger.debug("*** Grade: #{rowH['Grade']}, blank?: #{rowH['Grade'].blank?}")
    if rowH['Grade'].blank? &&
        rowH['Proposed Grade'].blank? &&
        rowH['Unit'].blank? &&
        rowH['Unit Name'].blank? &&
        rowH[' Sub unit'].blank? &&
        rowH['Proposed Student Competences'].blank? &&
        rowH['LO Code:'].blank? &&
        rowH['K-12 Big Idea '].blank? &&
        rowH['Specific big idea'].blank? &&
        rowH['Associated Practices'].blank? &&
        rowH['Explanatory Comments'].blank? &&
        rowH['Misconceptions'].blank? &&
        rowH['Misconception'].blank? &&
        rowH['Display relations'].blank? &&
        rowH['Resourcs'].blank?
      Rails.logger.debug("*** blank rowH: #{rowH.inspect}")
      return 'blank'
    else
      Rails.logger.debug("*** NON BLANK rowH: #{rowH.inspect}")
      if (rowH['Grade'].blank? && rowH['Proposed Grade'].blank?) ||
          (rowH['Unit'].blank? && rowH['Unit Name'].blank?) ||
          (rowH['Proposed Student Competences'].blank? && rowH['LO Code:'].blank?)
        @treeTypeRec.dim_codes.split(",").each do |dim_code|
          if !rowH[@dimTypeTitleByCode[dim_code]].blank?
            return 'dimensions'
          end
        end
        return 'invalid'
      else
        return 'valid'
      end
    end
  end

  def writeTreeRecord(depth, parentCodeA, codeA, thisCode, thisCodeTransl, currentRec, explainText, rowH)
    codeStr = codeA.join('.')
    Rails.logger.debug("*** writeTreeRecord codeStr: #{codeStr}, thisCode: #{thisCode}, thisCodeTransl: #{thisCodeTransl}")
    codeA2 = codeA.clone
    reportRecord = true
    wroteRecord = true
    if thisCodeTransl.blank? && thisCode.blank?
      # create tree items to be ignored (e.g. optional sub-unit to not show in tree displays)
      baseKeyStr = ''
      reportRecord = false
      # wroteRecord = true # for clarity
    else
      baseKeyStr = @baseKeyRoot + '.' + codeStr
    end
    if currentRec.blank?
      outRecId = getOrCreateOutcome(depth, baseKeyStr, rowH)
      Rails.logger.debug("+++ outRecId: #{outRecId}")
      rec = Tree.create(
        tree_type_id: @treeTypeRec.id,
        version_id: @treeTypeRec.version_id,
        subject_id: @subjectRec.id,
        grade_band_id: @gradeBandRec.id,
        code: codeStr,
        base_key: baseKeyStr,
        depth: depth,
        sort_order: @recordOrder,
        sequence_order: @recordOrder,
        outcome_id: outRecId
      )
      rptErrorMsg = ''
      if rec.errors.count > 0
        Rails.logger.debug("+++ error creating tree rec: #{rec.errors.inspect}")
        rptErrorMsg = rec.errors.full_messages
      else
        Rails.logger.debug("+++ created tree rec: #{rec.inspect}")
        rptErrorMsg = 'Created'
      end

    elsif currentRec[:updated]
      # don't bother updating it again this upload
      Rails.logger.debug("+++ currentRec updated is #{currentRec[:updated]}")
      rptRec = nil
      reportRecord = false
      wroteRecord = false
    else
      Rails.logger.debug("+++ currentRec not updated is #{currentRec[:updated]}")
      outRecId = getOrCreateOutcome(depth, baseKeyStr, rowH)
      Rails.logger.debug("+++ outRecId: #{outRecId}")
      rec = Tree.update(currentRec[:rec].id,
        tree_type_id: @treeTypeRec.id,
        version_id: @treeTypeRec.version_id,
        subject_id: @subjectRec.id,
        grade_band_id: @gradeBandRec.id,
        code: codeStr,
        base_key: baseKeyStr,
        depth: depth,
        sort_order: @recordOrder,
        sequence_order: @recordOrder,
        outcome_id: outRecId
      )
      rptErrorMsg = ''
      if rec.errors.count > 0
        Rails.logger.debug("+++ error updating tree rec: #{rec.errors.inspect}")
        rptErrorMsg = rec.errors.full_messages
      else
        Rails.logger.debug("+++ created tree rec: #{rec.inspect}")
        rptErrorMsg = "Updated"
      end
    end
    if wroteRecord
      Tree::RESOURCE_TYPES.each do |type|
        resource_text = rowH["#{@hierarchies[depth]}::#{type}"]
        if !resource_text.blank?
          resource_text = BaseRec.process_resource_content(type, @resource_names['tree'][type], resource_text)
          resource_key = rec.get_resource_key(type)
          Translation.find_or_update_translation(
            @locale_code,
            resource_key,
            resource_text
          )
          rptErrorMsg += "#{rptErrorMsg.length > 0 ? ", " : "" }Updated Resource Type: #{type}"
        end
      end
      #map connected sectors that have not yet been mapped to this LO
      if depth == @treeTypeRec[:outcome_depth]
        colSectors = rowH[@sectorName]
        if colSectors.present?
          sectorIds = SectorTree.where(tree_id: rec.id).pluck("sector_id").uniq
          @sectorArrByKeyPhrase.each do |phrase_and_rec|
            phrase, sectorRec = phrase_and_rec
            if colSectors.downcase.include?(phrase) && !sectorIds.include?(sectorRec.id)
              SectorTree.create(tree_id: rec.id, sector_id: sectorRec.id)
            end
          end
        end
      end #map connected sectors
      # output the translation record if any changes
      transl_rec, text_status, transl_text = Translation.find_or_update_translation(
        @localeRec.code,
        "#{@baseKeyRoot}.#{codeA.join('.')}.name",
        thisCodeTransl
      )
      # update hashes
      Rails.logger.debug("+++ codeA.joined: #{codeA.join('.')}")
      @currentRecs[codeA.join('.')] = {updated: true, rec: rec, transl_name: thisCodeTransl, transl_id: transl_rec.id}
      Rails.logger.debug("+++ updated current rec [#{codeA.join('.')}]: #{@currentRecs[codeA.join('.')].inspect}")
      @lastSubCode[parentCodeA.join('.')] = {valuesAssigned: {thisCodeTransl => thisCode}, lastSubCode: thisCode}
    end
    if reportRecord
      # build report record array of values
      rptRec = [@rowNum.to_s]
      rptRec.concat(codeA2.concat(['','','','']).slice(0,5)) # get exactly 5 codes to output
      rptRec.concat([codeA.join('.'), "#{@hierarchies[depth]}: #{thisCodeTransl}", rptErrorMsg])
      Rails.logger.debug("+++ final rptRec: #{rptRec.inspect}")
      Rails.logger.debug("+++ at end currentRec updated: #{currentRec[:updated]}")
    end
    return rptRec
  end

  def getOrCreateOutcome(depth, baseKeyStr, rowH)
    if depth == @treeTypeRec.outcome_depth
      outRecs = Outcome.where(base_key: baseKeyStr+'.outc')
      if outRecs.count > 0
        outRec = outRecs.first
        Rails.logger.debug("*** found outrec: #{outRec.inspect}")
      else
        outRec = Outcome.create(base_key: baseKeyStr+'.outc')
        Rails.logger.debug("*** created outrec: #{outRec.inspect}")
      end
      outRecId = outRec.id
      Outcome::RESOURCE_TYPES.each do |type|
        resource_text = rowH["Learning Outcome::#{type}"]
        if resource_text.present?
          resource_text = BaseRec.process_resource_content(type, @resource_names['outcome'][type], resource_text)
          resource_key = outRec.get_resource_key(type)
          Translation.find_or_update_translation(
            @locale_code,
            resource_key,
            resource_text
          )
        end
      end
    else
      outRecId = nil
    end
    return outRecId
  end


  def v1FileUpload(filePath, separator)
    # File.foreach(upload_params['file'].path).with_index do |line, line_num|
    File.foreach(filePath).with_index do |line, line_num|
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
  end

  def find_upload
    if params[:id].to_i != 0
      @upload = Upload.find(params[:id])
    elsif params[:phase] == "0" && upload_params[:subject_id].present? &&
      upload_params['file'].original_filename.split('.').last == 'csv'
      @upload = Upload.where(
          tree_type_code: @treeTypeRec.code,
          subject_id: upload_params[:subject_id],
          locale_id: Locale.where(:code => @locale_code).first.id,
          filename: upload_params['file'].original_filename
        ).first || Upload.create(
          tree_type_code: @treeTypeRec.code,
          subject_id: upload_params[:subject_id],
          grade_band_id: nil,
          locale_id: Locale.where(:code => @locale_code).first.id,
          status: 0,
          filename: upload_params['file'].original_filename
        )
    end
  end

  def upload_params
    params.require('upload').permit(:subject_id, :grade_band_id, :locale_id, :status, :file, :phase, :upload)
    # # ToDo - what is the upload param for ???
    # # params.permit(:subject_id, :grade_band_id, :locale_id, :status, :file, :phase, :upload)
    # params.permit(:utf8, :authenticity_token, :upload, :locale, :id, :phase)
  end

  def index_prep
    # @uploads = Upload.order(:id).includes([:subject, :grade_band, :locale]).where(:tree_type_code => @treeTypeRec.code).upload_listing
    @uploads = Upload.order(:id).includes([:subject, :locale]).where(:tree_type_code => @treeTypeRec.code).upload_listing
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

  # Use when new curriculum has been uploaded for a
  # Subject to update the Subject's max_grade and min_grade
  # seems to be not working.  Look at set_min_max_grades.rake
  def updateSubjectGrades(s)
    subj_gbs = GradeBand.where(:id => Tree.where(subject_id: s.id).pluck('grade_band_id').uniq)
    min_grade = subj_gbs.pluck("min_grade").min
    max_grade = subj_gbs.pluck("max_grade").max
    if min_grade && max_grade
      s.min_grade = min_grade
      s.max_grade = max_grade
      begin
        s.save!
        Rails.logger.debug("Updated Subject #{s[:code]}: min_grade = #{s[:min_grade]} and max_grade = #{s[:max_grade]}")
      rescue
        Rails.logger.error("Failed to update Subject #{s[:code]} with values: min_grade = #{s[:min_grade]} and max_grade = #{s[:max_grade]}")
      end
    end
  end


  def createOrUpdateDimRecs(treeRec, subject_id, dim_type, min_grade, max_grade, subject_code, dim_name, dim_tree_expl, rowH)
    # be able to update Dimension, DimTree (for the tree passed in), and their Translations
    # no updates to Tree
    # note: we are not using dim_desc_key!!!  this is not used.
    # note: we are not using dim_code!!! this is not used
    # note: we are defaulting the dim_order field

    # 1 - look up dimension by subject, dim type, and dim_name
    #   - create or update dimension, dim_name translation, and dim_desc translation
    #   - Create a hash - @currentDims of the Dimensions for this subject, and dimension type (not by Tree Type - to prevent dups)

    #   - if the dim_name exists already we are going to use that dimension (ignoring dim_desc)
    #   - otherwise we will create a new dimension

    currentRecH = @currentDims[dim_type][dim_name]
    currentRec = nil
    createdOrUpdated = ''
    if !currentRecH.present?
      Rails.logger.debug("$$$ Did NOT find current dimension: #{dim_name}")
      currentRec = Dimension.create(
        subject_id: subject_id,
        dim_type: dim_type,
        dim_code: dim_type,
        # dim_name_key: dim_name_key,
        min_grade: min_grade,
        max_grade: max_grade,
        subject_code: subject_code
      )
      currentRec.dim_name_key = currentRec.get_dim_name_key
      currentRec.save

      transl_rec, text_status, transl_text = Translation.find_or_update_translation(
        @localeRec.code,
        currentRec.get_dim_name_key,
        dim_name
      )
      createdOrUpdated = 'Created'
      if treeRec
        dimExplKey = DimTree.getDimExplanationKey(treeRec[:rec].id, dim_type, currentRec.id)
        dimTree = DimTree.create(
          tree_id: treeRec[:rec].id,
          dimension_id: currentRec.id,
          dim_explanation_key: dimExplKey
        )
        transl_rec, text_status, transl_text = Translation.find_or_update_translation(
          @localeRec.code,
          dimExplKey,
          dim_tree_expl
        )
        createdOrUpdated += '  and Mapped'
      end #if treeRec
      @currentDims[dim_type][dim_name] = {updated: true, rec: currentRec, transl_name: dim_name, transl_id: transl_rec.id}
    else #existing Dimension record
      Rails.logger.debug("$$$ Found current dimension: #{dim_name}")
      currentRec = currentRecH[:rec]
      Rails.logger.debug("$$$ current dimension record: #{currentRec.inspect}")
      currentRec.min_grade = min_grade if min_grade < currentRec.min_grade
      currentRec.max_grade = max_grade if max_grade > currentRec.max_grade
      currentRec.save
      if treeRec
        dimExplKey = DimTree.getDimExplanationKey(treeRec[:rec].id, dim_type, currentRec.id)
        dimTrees = DimTree.where(tree_id: treeRec[:rec].id, dimension_id: currentRec.id)
        if dimTrees.count < 1
          dimTree = DimTree.create(
            tree_id: treeRec[:rec].id,
            dimension_id: currentRec.id,
            dim_explanation_key: dimExplKey
          )
          transl_rec, text_status, transl_text = Translation.find_or_update_translation(
            @localeRec.code,
            dimExplKey,
            dim_tree_expl
          )
          @currentDims[dim_type][dim_name][:updated] = true
          createdOrUpdated = 'Mapped'
        end
      end #if treeRec
    end
    if currentRec && rowH
      Dimension::RESOURCE_TYPES.each do |type|
        resource_text = rowH["#{@dimTypeTitleByCode[dim_type]}::#{type}"]
        if !resource_text.blank?
          resource_text = BaseRec.process_resource_content(type, @resource_names['dim'][type], resource_text)
          currentRec.reload
          resource_key = currentRec.resource_key(type)
          Translation.find_or_update_translation(
            @locale_code,
            resource_key,
            resource_text
          )
          createdOrUpdated += "#{", " if createdOrUpdated.length > 0}updated resource type: #{type}"
        end
      end
    end
    return createdOrUpdated
  end # end createOrUpdateDimRecs

  def parseGrades(gradeStr)
    grades = gradeStr.split('-')
    post_secondary = {:min => 13, :max => GradeBand::MAX_GRADE}
    ret = {}
    if grades[0].downcase == 'adult' || grades[0].downcase == 'college'
      ret = post_secondary
    elsif grades.length == 2
      # 'k' will be converted to 0 by the .to_i method
      ret[:min] = grades[0].to_i
      ret[:max] = (grades[1].downcase == 'college' ? GradeBand::MAX_GRADE : grades[1].to_i)
    end
    return ret
  end #end def parseGrades(gradeStr)

  def build_resource_names
    @resource_names = Hash.new { |h, k| h[k] = {} }
    resource_types_by_key = {}
    lookupkeys = []
    Outcome::RESOURCE_TYPES.each do |t|
      key = Outcome.get_resource_key(t, @treeTypeRec.code, @versionRec.code)
      resource_types_by_key[key] = ['outcome', t]
      lookupkeys << key
    end
    Tree::RESOURCE_TYPES.map do |t|
      key = Tree.get_resource_type_key(t, @treeTypeRec.code, @versionRec.code)
      resource_types_by_key[key] = ['tree', t]
      lookupkeys << key
    end
    Dimension::RESOURCE_TYPES.map do |t|
      key = Dimension.get_dim_type_key(t, @treeTypeRec.code, @versionRec.code)
      resource_types_by_key[key] = ['dim', t]
      lookupkeys << key
    end
    nameTranslations = Translation.where(
      locale: @locale_code,
      key: lookupkeys
    )
    nameTranslations.each do |rec|
      rtArr = resource_types_by_key[rec.key]
      if rtArr
        @resource_names[rtArr[0]][rtArr[1]] = rec.value
      end
    end
  end

end
