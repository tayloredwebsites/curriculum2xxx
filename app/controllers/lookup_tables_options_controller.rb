class LookupTablesOptionsController < ApplicationController
  before_action :authenticate_user!

	# def bulk_edit
	# 	@options, translKeys = LookupTablesOption.get_table_array_and_keys(
	# 		@treeTypeRec.code,
	# 		@versionRec.code,
	# 		option_params[:table_name]
	# 	)
	# 	@translations = Translation.translationsByKeys(
	# 		@locale_code,
	# 		translKeys
	# 	)
	# 	respond_to do |format|
 #      format.js
 #    end
	# end

  def new
    @options = LookupTablesOption.new
    @optionsByTable = Hash.new { |h, k| h[k] = [] }
    LookupTablesOption.where(
        table_name: option_params[:table_names]
      ).each { |opt| @optionsByTable[opt.table_name] << Translation.find_translation_name(
        @locale_code,
        opt.name_key,
        opt.lookup_code
      ) }

    tableNameTranslations = option_params[:table_names].map do |n|
      [
        n,
        Translation.find_translation_name(
          @locale_code,
          LookupTablesOption.get_label_key(@treeTypeRec.code, @versionRec.code, n),
          n
        )
      ]
    end
    @tableNameTranslations = Hash[tableNameTranslations]

    respond_to do |format|
     format.html { render 'lookup_tables_options/edit' }
     format.js { render 'shared/edit', :locals => {:edit_partial => 'lookup_tables_options/edit' } }
    end
  end

  def create
    option_params[:table_names].each_with_index do |table_name, ix|
      translations = translation_params[:values][ix].split(',')
      translations.each do |tr|
        opt = LookupTablesOption.create(
          table_name: table_name,
          lookup_code: tr,
        )
        Translation.create(
          locale: @locale_code,
          key: opt.name_key,
          value: tr
        )
      end # translations.each do |tr|
    end # option_params[:table_names].each_with_index do |table_name, ix|
    respond_to do |format|
     format.js { render 'shared/update' }
    end
  end

	private

	  def option_params
      if params[:option]
        params.require(:option).permit(
          :id,
          :table_name,
          :table_names => [],
          :lookup_codes => [],
        )
      else
        nil
      end
    end

    def translation_params
      if params[:translation]
      params.require(:translation).permit(
        :id,
        :locale_code,
        :translation_keys => [],
        :values => [],
      )
      else
        nil
      end
    end
end