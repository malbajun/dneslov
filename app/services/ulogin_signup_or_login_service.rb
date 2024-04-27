class UloginSignupOrLoginService
   class InvalidNetworkToLogin < StandardError; end

#  {"photo_big"=>
#   "https://sun1-85.userapi.com/s/v1/ig2/BIM9eyKhBQEpTeRn3zki7maHIOGPYtrzHeqjDjqnkXlSzbLse_Lbuc2lE2V2VkICR0DE8HgHKS-MJMPeb87AqpxY.jpg?size=400x400&quality=95&crop=0,0,537,537&ava=1",
#  "identity"=>"http://vk.com/id239061672",
#  "network"=>"vkontakte",
#  "verified_email"=>"1",
#  "bdate"=>"30.7.1977",
#  "email"=>"majioa@yandex.ru",
#  "photo"=>
#   "https://sun1-85.userapi.com/s/v1/ig2/Yb_5eBoT-zbPACGyxCCVN7P5I_p_ISkgGfTZIUTvKnd_AktNIxEqCBShRJXQcB3VkW-kwgOHkolpNTwDsKKffjLo.jpg?size=50x50&quality=95&crop=0,0,537,537&ava=1",
#  "original_city"=>"Москва",
#  "sex"=>"2",
#  "last_name"=>"Skrylev",
#  "first_name"=>"Mal",
#  "nickname"=>"majioa",
#  "uid"=>"239061672",
#  "profile"=>"http://vk.com/id239061672"}

   MAP = {
      "vkontakte" => "Vk",
      "odnoklassniki" => "Ok",
      "mailru" => "Mailru",
      "twitter" => "X",
      "livejournal" => "Lj"
   }

   attr_reader :info

   def initialize info
      @info = {
         'uid': info['uid'],
         'network': info['network'],
         'avatar_url': info['photo_big'] || info['photo'],
         'email': info['email'],
         'profile': info['profile'],
         'last_name': info['last_name'],
         'first_name': info['first_name'],
         'nickname': info['nickname'],
         'place': info['original_city'],
         'birth_date': info['bdate'],
         'sex': info['sex'] == "2" ? "m" : info['sex'] == "1" ? "f" : "b",
         'jwt': JwToken.encode("#{info["network"]}##{info['uid']}"),
         'info': info
      }
   end

   def user
      @user = User.by_accounts(hash).first || user_create
   end

   def user_create
      user = User.new(accounts_attributes: hash.map {|(x, y)| {type: x, no: y}})

      user.save!(validate: false)

      user
   rescue Exception
      binding.pry
   end

   def do
      user
   end

   def hash
      hash = {}

      hash[type] = info[:uid] if info[:uid]
      hash["Account::Email"] = info[:email] if info[:email]

      hash
   end

#   def accounts
#      accounts = []
#
#      accounts << Account::Email.new(no: info[:email]) if info[:email]
#      accounts << Account.new(no: info[:uid], type: type) if info[:uid]
#
#      accounts
#   end

   def type
      net = MAP[info[:network]] || raise(InvalidNetworkToLogin)

      "Account::#{net}"
   end
end
