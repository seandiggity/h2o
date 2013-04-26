Case.new
Collage.new
PlaylistPusher.new
User.non_versioned_columns << 'persistence_token'
User.non_versioned_columns << 'login_count'
User.non_versioned_columns << 'last_login_at'
User.non_versioned_columns << 'current_login_at'
User.non_versioned_columns << 'last_login_ip'
User.non_versioned_columns << 'current_login_at'
