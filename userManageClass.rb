=begin

To Do:

test for user method

=end


require 'rubygems'
require 'mysql'
require 'digest/sha2'

@@con = Mysql.new('localhost', 'combatPets', 'evo123!!', 'combatPetsDatabase')

class UserManage

   def createNewUser
      puts "What do you want your username to be?"
      print "> "
      username = gets.chomp()
      resetValue = 0
      createNewPassword(username, resetValue)
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
      @@con = Mysql.new('localhost', 'combatPets', 'evo123!!', 'combatPetsDatabase')
      puts "Enter your secret phrase (100 characters max) for password resets"
      secretPhrase = gets.chomp()

      if secretPhrase == 0 or secretPhrase.length > 100
	puts "that is an invalid secret phrase"
	createSecretPhrase
      else
	@@con.query("INSERT INTO users(username, password, secret_phrase) VALUES(('#{username}'), ('#{hash}'), ('#{secretPhrase}'))")		
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

   def testForUser(username)        
	
       
   end

   def loginUser
      puts "Username:"
      print "> "
      loginName = gets.chomp().downcase
      puts "Password:"
      print "> "
      loginPassword = gets.chomp()
      
      loginHash = Digest::SHA2.new(256) << loginPassword
      loginHash = loginHash.to_s

      rows = @@con.query("SELECT password FROM users WHERE username = '#{loginName}'")
      rows.each do |row|
           @getPassword = row[0]
      end

      if @getPassword == loginHash
	   puts "Welcome back to Combat Pets #{loginName.capitalize}!"
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
	   exit
	else
	   puts "That is not a valid option."
	   userManageMenu
	end
   end

# End UserManage class
end

loginInstance = UserManage.new
loginInstance.userManageMenu 









