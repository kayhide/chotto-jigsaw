ENV.fetch("SEED_USERS") { "" }.split(";").each do |s|
  m = s.match(/(?<username>.+):(?<password>.+)<(?<email>.+@.+)>/)
  username = m["username"]&.strip
  email = m["email"]&.strip
  password = m["password"]&.strip
  User.create_or_find_by(username: username, email: email)
end
