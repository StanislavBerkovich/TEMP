class MediaContentsController < ApplicationController
  before_action :set_media_content, only: [:show, :edit, :update, :destroy]

  # GET /media_contents
  # GET /media_contents.json
  def index
    @media_contents = MediaContent.all
  end

  # GET /media_contents/1
  # GET /media_contents/1.json
  def show
  end

  # GET /media_contents/new
  def new
    @media_content = MediaContent.new
  end

  # GET /media_contents/1/edit
  def edit
  end

  # POST /media_contents
  # POST /media_contents.json
  def create
    @media_content = MediaContent.new(media_content_params)

    respond_to do |format|
      if @media_content.save
        format.html { redirect_to @media_content, notice: 'Media content was successfully created.' }
        format.json { render :show, status: :created, location: @media_content }
      else
        format.html { render :new }
        format.json { render json: @media_content.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /media_contents/1
  # PATCH/PUT /media_contents/1.json
  def update
    respond_to do |format|
      if @media_content.update(media_content_params)
        format.html { redirect_to @media_content, notice: 'Media content was successfully updated.' }
        format.json { render :show, status: :ok, location: @media_content }
      else
        format.html { render :edit }
        format.json { render json: @media_content.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /media_contents/1
  # DELETE /media_contents/1.json
  def destroy
    @media_content.destroy
    respond_to do |format|
      format.html { redirect_to media_contents_url, notice: 'Media content was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_media_content
    @media_content = MediaContent.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def media_content_params
    {file_name: params[:file]}
  end
end
