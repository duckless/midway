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

    midway_fika = find_fika middle_pos(@other_participant.last_location,@participant.last_location)

    render json: [{:session_id => @session.session_id, :location => midway_fika}]
  end

  def midpoint

  end

  protected
    def middle_pos(location1, location2)
      location1 = location1.split(",").map {|i| Float(i.strip)}
      location2 = location2.split(",").map {|i| Float(i.strip)}

      mid_point = "#{(location1[0]+location2[0])/2},#{(location1[1]+location2[1])/2}"
    end

    def find_fika(location)
      path = File.join(Rails.root, "config", "foursquare.yml")
      config = YAML.load_file(path)

      client = Foursquare2::Client.new(:client_id => config['foursquare']['client_id'], 
        :client_secret => config['foursquare']['client_secret'])

      venues = client.search_venues(:ll => location, 
        :categoryId => config['foursquare']['cafe_category_id'])
      location = venues['groups'][0]['items'][0]['location']
      "#{location[:lat]},#{location[:lng]}"
    end

end
