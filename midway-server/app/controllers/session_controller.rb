class SessionController < ApplicationController
  def start
    begin
      @participant = Participant.create!({:uuid => params[:uuid], :last_location => params[:last_location]})
    rescue
      render json: [{:error => "Insufficient parameters"}]
      return
    end

    @session = Session.create
    @session.participants << @participant

    render json: [{:session_id => @session.session_id}]
  end

  def join
    @session = Session.find_by_session_id(params[:session_id])
    if @session.nil?
      render json: [{:error => "Invalid session"}]
      return
    end

    begin
      @participant = Participant.create!({:uuid => params[:uuid], :last_location => params[:last_location]})
    rescue
      render json: [{:error => "Insufficient parameters"}]
      return
    end

    @other_participant = Participant.find_by_session_id(@session.id)
    @session.participants << @participant

    render json: [{:session_id => @session.session_id, :location => @other_participant.last_location}]
  end

  def midpoint

  end

end
