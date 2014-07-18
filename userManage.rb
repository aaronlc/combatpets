require 'rubygems'
require 'mysql'
require 'digest/sha2'
#require_relative 'gameManage'

@@con = Mysql.new('localhost', 'combatPets', 'evo123!!', 'combatPetsDatabase')

class UserManage

   def createNewUser
      puts "What do you want your username to be?"
      print "> "
      @newUsername = gets.chomp().downcase
      resetValue = 0
      @getNewUsername = " "
      
      rows = @@con.query("SELECT username FROM users WHERE username = '#{@newUsername}'")
      rows.each do |row|
           @getNewUsername = row[0]
	   puts @getNewUsername
      end

      if @getNewUsername.nil? or @getNewUsername == " "
        createNewPassword(@newUsername, resetValue)
      else
	puts "That username is already taken."
	puts " "
	createNewUser
      end 

   end

   def createNewPassword(username, resetValue)
      puts "What do you want your password to be?"
      print "> "
      plainText = gets.chomp()

      puts "Re-enter you password to confirm"
      print "> "
      plainTextConfirm = gets.chomp()

      if plainText == plainTextConfirm and resetValue == 0
        hash = Digest::SHA2.new(256) << plainText
        hash = hash.to_s
	createSecretPhrase(username, hash)
      elsif plainText == plainTextConfirm and resetValue == 1
	resetHash = Digest::SHA2.new(256) << plainText
        resetHash = resetHash.to_s      
	con.query("UPDATE users SET password='#{resetHash}' WHERE username = '#{username}'")
	puts "Password has been reset!"
	userManageMenu
      else
	createNewPassword  
      end
   end
   
   def createSecretPhrase(username, hash)
      puts "Enter your secret phrase (100 characters max) for password resets"
      secretPhrase = gets.chomp()

      if secretPhrase == 0 or secretPhrase.length > 100
	puts "that is an invalid secret phrase"
	createSecretPhrase
      else
	@@con.query("INSERT INTO users(username, password, secret_phrase) VALUES(('#{username}'), ('#{hash}'), ('#{secretPhrase}'))")		
	puts "Welcome to Combat Pets #{username}! Now you can login and play!"
	loginUser
      end
   end

   def resetPassword
      puts "Combat Pets Password Reset"
      puts "Username: "
      print "> "
      resetUsername = gets.chomp()
      
      rows = @@con.query("SELECT username, password, secret_phrase FROM users WHERE username = '#{resetUsername}'")
      rows.each do |row|
           getUsername = row[0]
	   getPassword = row[1]
	   @getSecretPhrase = row[2]
      end

	puts "Enter your secret phrase: "
	print "> "
	enteredSecretPhrase = gets.chomp()
		
        if enteredSecretPhrase == @getSecretPhrase
	   resetValue = 1
	   createNewPassword(resetUsername, resetValue) 
	else
	   puts "Secret phrase was incorrect"
	   userManageMenu
	end
   end   

   def loginUser
      puts "Username:"
      print "> "
      loginName = gets.chomp().downcase

      rows = @@con.query("SELECT username, password FROM users WHERE username = '#{loginName}'")
      rows.each do |row|
           @checkName = row[0]
           @getPassword = row[1]
      end

      if @checkName.nil?
        puts "There is no user with that name."
        userManageMenu
      end

      puts "Password:"
      print "> "
      loginPassword = gets.chomp()
      
      loginHash = Digest::SHA2.new(256) << loginPassword
      loginHash = loginHash.to_s

        if @getPassword == loginHash
              newGame = StartGame.new
	      newGame.gamePrompt
        else
              puts "Password incorrect."
              loginUser
        end
   end      

   def userManageMenu
	puts "Combat Pets Login Menu"
	puts "1: Create new user"
	puts "2: Login exisiting user"
	puts "3: Reset your password"
	puts "4: Exit"
	puts "Enter a menu item number:"
	print "> "
	menuChoice = gets.chomp()

	if menuChoice == "1"
	   createNewUser
	elsif menuChoice == "2"
	   loginUser
	elsif menuChoice == "3"
	   resetPassword
	elsif menuChoice == "4"
	   puts "Goodbye!"
	   exit
	else
	   puts "That is not a valid option."
	   userManageMenu
	end
   end

# End UserManage class
end

# loginInstance = UserManage.new
# loginInstance.userManageMenu 









