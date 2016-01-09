class ConfsController < ApplicationController
  before_action :set_conf, only: [:show, :edit, :update, :destroy]

  # GET /confs
  # GET /confs.json
  def index
    @confs = Conf.all
  end

  # GET /confs/1
  # GET /confs/1.json
  def show
  end

  # GET /confs/new
  def new
    @conf = Conf.new
  end

  # GET /confs/1/edit
  def edit
  end

  # POST /confs
  # POST /confs.json
  def create
    @conf = Conf.new(conf_params)

    respond_to do |format|
      if @conf.save
        format.html { redirect_to @conf, notice: 'Conf was successfully created.' }
        format.json { render :show, status: :created, location: @conf }
      else
        format.html { render :new }
        format.json { render json: @conf.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /confs/1
  # PATCH/PUT /confs/1.json
  def update
    respond_to do |format|
      if @conf.update(conf_params)
        format.html { redirect_to @conf, notice: 'Conf was successfully updated.' }
        format.json { render :show, status: :ok, location: @conf }
      else
        format.html { render :edit }
        format.json { render json: @conf.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /confs/1
  # DELETE /confs/1.json
  def destroy
    @conf.destroy
    respond_to do |format|
      format.html { redirect_to confs_url, notice: 'Conf was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_conf
      @conf = Conf.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def conf_params
      params.require(:conf).permit(:exercise_count, :repository_base)
    end
end
