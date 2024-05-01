module ImporterLogic
  # allow access to broadcast_replace_to without needed Turbo::StreamsChannel prefix
  include Turbo::Streams::Broadcasts, Turbo::Streams::StreamName

  # def import_workout(data)
  #   user_id = data['user_id']
  #
  #   # attempt to find user in memory. returns user or nil
  #   user = @users[user_id]
  #
  #   # if user doesn't exist in hash, find or create user in database and assign
  #   # in hash
  #   unless user
  #     user = User.find_or_create_by(hevy_id: user_id) do |u|
  #       # full_name:   data[''], # don't exist in this payload
  #       u.username    = data['username']
  #       u.profile_pic = data['profile_image']
  #       u.private     = data['is_private']
  #       u.verified    = data['verified']
  #     end
  #
  #     @users[user_id] = user
  #   end
  #
  #   user.workouts.find_or_create_by(hevy_id: data['id']) do |workout|
  #     # workout.like_count = workout_data['like_count'] # do this on workout.update_likes
  #     workout.index = data['index']
  #     workout.number = data['nth_workout']
  #     workout.created_at = Time.parse data['created_at']
  #     workout.last_sync = Time.now
  #   end
  # end
  #
  # def update_likes(workout, data)
  #   likes = []
  #
  #   # make user like workout UNLESS THE LIKE ALREADY EXISTS
  #   # first load all likes from workout
  #   # get liker ids outside of loop to avoid useless attachments
  #   # workout_likes = workout.likes
  #   liker_ids = workout.likes.pluck :user_id
  #
  #   data.each do |datum|
  #     user_id = datum['id']
  #
  #     # attempt to find user in memory. returns user or nil
  #     liker = @users[user_id]
  #
  #     unless liker
  #       # puts "liker not found"
  #       liker = User.find_or_create_by(hevy_id: user_id) do |liker|
  #         liker.full_name   = datum['full_name']
  #         liker.username    = datum['username']
  #         liker.profile_pic = datum['profile_pic']
  #         liker.private     = datum['private_profile']
  #         liker.verified    = datum['verified']
  #       end
  #
  #       @users[user_id] = liker # for some reason this causes the threads to get stuck even with mutex
  #     end
  #
  #     # create follower if needed
  #     # follower creation could be done in bulk
  #     if datum['following_status'] == 'following'
  #       liker.passive_follows.find_or_create_by follower_id: workout.user_id
  #       # workout.user.active_follows.find_or_create_by followed: liker
  #     end
  #
  #     # workout.likes.find_or_create_by user: liker # seems to prevent duplicates, but we should also add validations against duplicates just in case
  #     # instantiate like and add it to likes array if not found in ID
  #     # like = workout.likes.find_or_initialize_by user: liker
  #     # like = Like.find_or_initialize_by user_id: liker.id, workout_id: workout.id # must instantiate from Like class to avoid adding instance directly to workout. causes validations to run when trying to update workout.like_count later in the job
  #     # stamp "like persisted?: #{like.persisted?}", :pink
  #     if !liker_ids.include? liker.id
  #       like = Like.new user_id: liker.id, workout_id: workout.id # must instantiate from Like class to avoid adding instance directly to workout. causes validations to run when trying to update workout.like_count later in the job
  #       likes << like
  #     end
  #   end
  #
  #   # stamp "likes: #{likes.count}", :pink
  #   # stamp "about to import...", :gray, true
  #   Like.import likes
  #   # stamp "done!", :green
  #
  #   # update workout.like_count so next time we can use it to know if we need to
  #   # run this method again or skip it
  #   workout.update like_count: workout.likes.count
  #   # p "errors: #{workout.errors.to_a}" if workout.errors.any?
  #   # debugger if workout.errors.any?
  # end
  #
  # def update_comments(workout, data)
  #   comments = []
  #
  #   # make user like workout UNLESS THE LIKE ALREADY EXISTS
  #   # first load all likes from workout
  #   # get liker ids outside of loop to avoid useless attachments
  #   # workout_likes = workout.likes
  #   comment_ids = workout.comments.pluck :hevy_id
  #
  #   # {
  #   #   "id"=>1432906,
  #   #   "username"=>"nuttbran",
  #   #   "verified"=>false,
  #   #   "profile_pic"=>"https://d2l9nsnmtah87f.cloudfront.net/profile-images/nuttbran-b30ce0a2-1cb1-404b-bd9b-7fa1dac89301.jpg",
  #   #   "comment"=>"Impressive dude! 🔥 Great work! 💪💪",
  #   #   "created_at"=>"2023-12-21T11:55:53.789Z"
  #   # },
  #   data.each do |datum|
  #     username = datum['username']
  #
  #     # attempt to find user in memory. returns user or nil
  #     commenter = @users[username]
  #
  #     # if commenter not in memory
  #     unless commenter
  #       # find one in database
  #       commenter = User.find_by_username username
  #
  #       # if not found in database, go fetch info and create commenter in db
  #       if commenter
  #         @in_db += 1
  #       else
  #         @non_db += 1
  #         api_start = Time.now
  #         users_data = @api.search_user username
  #         @api_time += Time.now - api_start
  #
  #         user_data = users_data.find { |x| x['username'] == username }
  #
  #         hevy_id     = user_data['id']
  #         full_name   = user_data['full_name']
  #         profile_pic = user_data['profile_pic']
  #         private     = user_data['private_profile']
  #         verified    = user_data['verified']
  #
  #         commenter = User.create(
  #           hevy_id: hevy_id, full_name: full_name, username: username,
  #           profile_pic: profile_pic, private: private, verified: verified
  #         )
  #       end
  #
  #       @users[username] = commenter
  #     end
  #
  #     # create new comment if it doesn't exist
  #     # puts "workout ##{workout.number}"
  #     # puts "  comment_ids: #{comment_ids}"
  #     # puts "  datum['id']: #{datum['id']}"
  #     comment_exists = comment_ids.include? datum['id']
  #     if !comment_exists
  #       hevy_id    = datum['id']
  #       comment    = datum['comment']
  #       created_at = datum['created_at']
  #
  #       comment = Comment.new hevy_id: hevy_id, user_id: commenter.id, workout_id: workout.id, comment: comment, created_at: created_at
  #       comments << comment
  #     end
  #   end
  #
  #   # stamp "likes: #{likes.count}", :pink
  #   # stamp "about to import...", :gray, true
  #   @mutex.synchronize do
  #     Comment.import comments
  #     # stamp "done!", :green
  #
  #     # update workout.like_count so next time we can use it to know if we need to
  #     # run this method again or skip it
  #     workout.update comment_count: workout.comments.count
  #     # p "errors: #{workout.errors.to_a}" if workout.errors.any?
  #     # debugger if workout.errors.any?
  #   end
  # end

  def stamp(message, color = :red, inline = false)
    colors = { gray: 90, red: 91, green: 92, yellow: 93, purple: 94, pink: 95, cyan: 96 }
    style = '1;5;'
    style << colors[color].to_s

    if inline
      print "\e[#{style}m#{message}\e[0m"
    else
      puts "\e[#{style}m#{message}\e[0m"
    end
  end

  def print_results
    @stop = Time.now
    delta = @stop - @start
    rate = @total / delta
    stamp "Finished in #{(delta).round 4}s"
    stamp "  #{@total} total"
    stamp "  #{rate.round 1} per second"
    stamp "  #{@api_time.round 2}s (#{(@api_time / delta * 100).round 2}%) waiting for API"
    stamp "|#{@total}|#{delta.round 2}s|#{rate.round 1}/s|#{@api_time.round 2}s|#{(@api_time / delta * 100).round 2}%|", :green
  end

  # def broadcast_status(status)
  #   icons = {
  #     working: '<i class="fa-solid fa-spinner fa-spin-pulse fa-spin"></i>',
  #     done: '<i class="fa-solid fa-check fade-in"></i>',
  #     error: '<i class="fa-solid fa-xmark" style="color: crimson;"></i>'
  #   }
  #   icon = icons[status]
  #   broadcast_update_to @stream, target: 'status', plain: icon
  # end
end
