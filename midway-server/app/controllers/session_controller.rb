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
    
  end

  def midpoint
  end
end
