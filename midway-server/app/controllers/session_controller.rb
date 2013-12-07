class SessionController < ApplicationController
  def start
    begin
      @participant = Participant.create!({:uuid => params[:uuid], :last_location => params[:last_location]})
    rescue
      render json: {:error => "Insufficient parameters"}
      return
    end

    @session = Session.create
    @session.participants << @participant

    render json: {:session_id => @session.session_id}
  end

  def join
    @session = Session.find_by_session_id(params[:session_id])
    if @session.nil?
      render json: {:error => "Invalid session"}
      return
    end

    begin
      @participant = Participant.create!({:uuid => params[:uuid], :last_location => params[:last_location]})
    rescue
      render json: {:error => "Insufficient parameters"}
      return
    end

    @other_participant = Participant.find_by_session_id(@session.id)
    @session.participants << @participant

    midway_fika = find_fika middle_pos(@other_participant.last_location, @participant.last_location)

    send_push @other_participant.uuid, "Your friend has joined."

    render json: {:session_id => @session.session_id, :location => midway_fika}
  end

  def update
    @session = Session.find_by_session_id(params[:session_id])
    if @session.nil?
      render json: {:error => "Invalid session"}
      return
    end

    @participant = Participant.find_by_uuid(params[:uuid])
    if @participant.nil?
      render json: {:error => "Invalid uuid"}
      return
    end

    @other_participant = Participant.where(['session_id = ? AND id != ?', 
      @session.id, @participant.id])

    @participant.last_location = params[:last_location]
    @participant.save

    midway_fika = find_fika middle_pos(@other_participant.last_location, @participant.last_location)

    render json: {:session_id => @session_id.session_id, :location1 => midway_fika}
  end

  protected
    def send_push(uuid, message)
      require 'net/http'
      require "uri"

      parse = read_config 'parse'

      uri              = URI.parse("https://api.parse.com")
      http             = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl     = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new("/1/push")
      request.add_field('X-Parse-Application-Id', parse['application_id'])
      request.add_field('X-Parse-REST-API-Key', parse['rest_api_key'])
      request.add_field('Content-Type', 'application/json')

      request.body = {
        where: {deviceToken: uuid}, 
        data: {alert: message}
      }.to_json

      response = http.request(request)
    end

    def middle_pos(location1, location2)
      location1 = location1.split(",").map {|i| Float(i.strip)}
      location2 = location2.split(",").map {|i| Float(i.strip)}

      mid_point = "#{(location1[0]+location2[0])/2},#{(location1[1]+location2[1])/2}"
    end

    def read_config(name)
      path = File.join(Rails.root, "config", "#{name}.yml")
      config = YAML.load_file(path)
      config["#{name}"]
    end

    def find_fika(location)
      foursquare = read_config
      client = Foursquare2::Client.new(:client_id => foursquare['client_id'], 
        :client_secret => foursquare['client_secret'])

      venues = client.search_venues(:ll => location, 
        :categoryId => foursquare['cafe_category_id'])
      location = venues['groups'][0]['items'][0]['location']
      "#{location[:lat]},#{location[:lng]}"
    end

end
