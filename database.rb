class Database
  attr_accessor :user, :history, :url
  def initialize(url)
    file = File.open(url,'r+')
    data = JSON.parse(file.readlines[0])
    @user = data['user']
    @history = data['history']
    @url = url
    file.close
  end
  def save
    file = File.open(@url, 'w+')
    data = {user: @user, history: @history}
    file.write(JSON.generate(data))
    file.close
  end
end