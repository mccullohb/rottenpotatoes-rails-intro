class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    
    # Pull all types of ratings to display to user
    @all_ratings = Movie.order(:rating).pluck(:rating).uniq()
    
    # Assign movie ratings to return back to view; Either ratings specified by user or all
    # If no current ratings settings, check parameters
    if params[:ratings]
      @chosen_ratings = params[:ratings].keys
    elsif session[:ratings]
      @chosen_ratings = session[:ratings]
    else
      @chosen_ratings = @all_ratings
    end
    
    # "Check" assigned ratings
    @chosen_ratings.each do |rating|
      params[rating] = true
    end
    
    # Return either by column sort or by ratings checked
    if params[:sort_type] == "title"
      @movies = Movie.order(params[:sort_type]).where(:rating => @chosen_ratings)
      @title_header = "hilite"
    elsif params[:sort_type] == "release_date"
      @movies = Movie.order(params[:sort_type]).where(:rating => @chosen_ratings)
      @release_date_header = "hilite"
    elsif session[:sort_type] == "title"
      @movies = Movie.order(session[:sort_type]).where(:rating => @chosen_ratings)
      @title_header = "hilite"
    elsif session[:sort_type] == "release_date"
      @movies = Movie.order(session[:sort_type]).where(:rating => @chosen_ratings)
      @release_date_header = "hilite"
    else
      @movies = Movie.where(:rating => @chosen_ratings)
    end
    
    # Update sessions
    if params[:ratings] != nil
      session[:ratings] = params[:ratings].keys
    end
    
    if params[:sort_type] != nil
      session[:sort_type] = params[:sort_type]
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
