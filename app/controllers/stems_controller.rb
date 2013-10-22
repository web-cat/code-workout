class StemsController < ApplicationController
  before_action :set_stem, only: [:show, :edit, :update, :destroy]

  # GET /stems
  def index
    @stems = Stem.all
  end

  # GET /stems/1
  def show
  end

  # GET /stems/new
  def new
    @stem = Stem.new
  end

  # GET /stems/1/edit
  def edit
  end

  # POST /stems
  def create
    @stem = Stem.new(stem_params)

    if @stem.save
      redirect_to @stem, notice: 'Stem was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /stems/1
  def update
    if @stem.update(stem_params)
      redirect_to @stem, notice: 'Stem was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /stems/1
  def destroy
    @stem.destroy
    redirect_to stems_url, notice: 'Stem was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stem
      @stem = Stem.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def stem_params
      params.require(:stem).permit(:preamble)
    end
end
