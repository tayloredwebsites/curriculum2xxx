class TranslationsController < ApplicationController

  before_action :authenticate_user!
  before_action :find_translation, only: [:show, :edit, :update]

  # TRANSLATION_PARAMS = 'i18n_backend_active_record_translation'
  TRANSLATION_PARAMS = 'translation'

  def index
    if @locale_code
      @translations = Translation.where(locale: @locale_code).order('key')
    else
      @translations = Translation.all.order(:key, :locale)
    end
    respond_to do |format|
      format.html
      format.json { render json: @translations}
    end

  end

  def listing2
    @translations = Translation.all.order(:key, :locale)
  end

  def new
    @translation = Translation.new()
  end

  def create
    convert_p_text = translation_params[:value].gsub('<p>', '').split('</p>').join('<br>')
    @translation = Translation.new(
      locale: translation_params[:locale],
      key: translation_params[:key],
      value: convert_p_text,
    )
    if @translation.value == I18n.t(@translation.key, locale: @translation.locale)
      flash[:alert] = I18n.t('translations.errors.is_same_as_default')
      render :new
    else
      if @translation.save
        flash[:success] = I18n.t('translations.errors.updated_key', key: @key)
        # I18n.backend.reload!
        #redirect_to translations_path(@locale_code)
        respond_to do |format|
         format.js { render 'shared/update' }
        end
      else
        #render :new
        respond_to do |format|
         format.js { render 'shared/update' }
        end
      end
    end
  end

  def show
  end

  def edit
    @title = translation_params[:title]
    respond_to do |format|
     format.html
     format.js { render 'shared/edit', :locals => {:edit_partial => 'translations/edit' } }
    end
  end

  def update
    # if @translation.update(translation_params)
    #   flash[:notice] = I18n.t('translations.errors.updated_key', key: @key)
    #   # I18n.backend.reload!
    #   redirect_to translations_path(@locale_code)
    # else
    #   render :edit
    # end
    convert_p_text = translation_params[:value].gsub('<p>', '').split('</p>').join('<br>')
    @translation.update(
      locale: translation_params[:locale],
      key: translation_params[:key],
      value: convert_p_text,
    )
    respond_to do |format|
     format.js { render 'shared/update' }
    end
  end

  def reload
    I18n.backend.reload!
  end

  def new_layout
    params[:locale_id] = 'en'
    find_locale
    @translations = Translation.where(locale: @locale_code).order('key')
    render layout: 'responsive1'
  end

  private

  def find_translation
    if params[:id] && params[:id] != 'nil'
      @translation = Translation.find(params[:id])
    elsif translation_params[:key]
      @translation = Translation.where(
        key: translation_params[:key],
        locale: @locale_code
      ).first || Translation.new(
        key: translation_params[:key],
        locale: @locale_code
      )
    end
  end

  def translation_params
    params.require(TRANSLATION_PARAMS).permit(:locale,
      :key, :value, :title)
  end

end
