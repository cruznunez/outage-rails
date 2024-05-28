class OutagesController < ApplicationController
  before_action :set_outage, only: %i[ show edit update destroy ]

  # GET /outages or /outages.json
  def index
    if Outage.sqlite?
      @active_outages = Outage.where(ended_at: nil).order(id: :desc)
      @restorations = Outage.where.not(ended_at: nil)
    else
      @active_outages = Outage.where(outage_restored: false)
      @restorations = Outage.where(outage_restored: true)
    end
    avg_time = @restorations.sum { |o| o.ended_at - o.started_at } / @restorations.count rescue 0
    hours = (avg_time / (60 * 60)).to_i
    minutes = (avg_time % 60).to_i
    @avg_restore_time = ""
    @avg_restore_time << "#{hours}h" if hours.positive?
    @avg_restore_time << "#{minutes}m" if minutes.positive?
  end

  # GET /outages/fetch
  def fetch
    FetchOutagesJob.perform_later 'DEC'
    head :no_content
  end

  # GET /outages/map
  def map
    if Outage.sqlite?
      @outages = Outage.where(ended_at: nil).order(created_at: :desc)
    else
      @outages = Outage.where(outage_restored: false)
    end
  end

  # GET /outages/restored
  def restored
    if Outage.sqlite?
      @restored_outages = Outage.where.not(ended_at: nil)
                                .order(created_at: :desc)
                                .page(params[:p])
    else
      @restored_outages = Outage.where(outage_restored: true)
                                .order(started_at: :desc)
                                .page(params[:p])
    end

    avg_time = @restored_outages.sum { |o| o.ended_at - o.started_at } / @restored_outages.count rescue 0
    hours = (avg_time / (60 * 60)).to_i
    minutes = (avg_time % 60).to_i
    @avg_restore_time = ""
    @avg_restore_time << "#{hours}h" if hours.positive?
    @avg_restore_time << "#{minutes}m" if minutes.positive?
  end

  def fips
    redirect_to root_path if Outage.sqlite?
    @fips = Outage.average_restoration_time_by_fips
  end

  # GET /outages/1 or /outages/1.json
  def show
  end

  # GET /outages/new
  def new
    @outage = Outage.new
  end

  # GET /outages/1/edit
  def edit
  end

  # POST /outages or /outages.json
  def create
    @outage = Outage.new(outage_params)

    respond_to do |format|
      if @outage.save
        format.html { redirect_to outage_url(@outage), notice: "Outage was successfully created." }
        format.json { render :show, status: :created, location: @outage }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @outage.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /outages/1 or /outages/1.json
  def update
    respond_to do |format|
      if @outage.update(outage_params)
        format.html { redirect_to outage_url(@outage), notice: "Outage was successfully updated." }
        format.json { render :show, status: :ok, location: @outage }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @outage.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /outages/1 or /outages/1.json
  def destroy
    @outage.destroy!

    respond_to do |format|
      format.html { redirect_to outages_url, notice: "Outage was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_outage
      @outage = Outage.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def outage_params
      params.require(:outage).permit(:eid, :device_lat, :device_lng, :customers_affected, :cause, :jurisdiction, :convex_hull, :started_at, :ended_at, :attempts)
    end
end
