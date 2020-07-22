class LookupTablesOptionsController < ApplicationController
  before_action :authenticate_user!

	def bulk_edit
		@options, translKeys = LookupTablesOption.get_table_array_and_keys(
			@treeTypeRec.code,
			@versionRec.code,
			option_params[:table_name]
		)
		@translations = Translation.translationsByKeys(
			@locale_code,
			translKeys
		)
		respond_to do |format|
      format.js
    end
	end

	private

	  def option_params
      if params[:option]
      params.require(:resource).permit(
        :id,
        :table_name,
        :lookup_codes => [],
      )
      else
        nil
      end
    end

    def translation_params
      if params[:lookup_tables_option]
      params.require(:resource).permit(
        :id,
        :locale_code,
        :translation_keys => [],
        :translation_values => [],
      )
      else
        nil
      end
    end
end