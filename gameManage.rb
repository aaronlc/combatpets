# Combat Pets Alpha
# Create a pet and battle others!
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

require_relative 'userManage'

@@con = Mysql.new('localhost', 'combatPets', 'evo123!!', 'combatPetsDatabase')

class StartGame

   def gamePrompt

        system("clear")
        puts "Welcome to Combat Pets!"
        puts "Would you like to: "
        puts "1: Start a new pet "
        puts "2: Load an existing pet "
        puts "3: Exit"
        puts "Enter a menu item number: "
        print "> "
        loadOrNew = gets.chomp()

        if loadOrNew == "1"
           createNewPet(" ")
        elsif loadOrNew == "2"
           loadPet
        elsif loadOrNew == "3"
           puts "Goodbye!"
           exit
        else
           "That is not a valid option."
           gamePrompt
        end
   end

   def createNewPet(name)
        if name == " "
           puts "What would you like your pet to be named?"
           print "> "
           name = gets.chomp()
        else
           puts "Your pet will be named #{name}."
        end

        puts "What type of pet do you want #{name} to be?"
	puts "1: Wolf"
	puts "2: Panther"
	puts "3: Squirrel"
        print "> "
	getType = gets.chomp()

	if getType == "1"
	   type = "Wolf"
	elsif getType == "2"
	   type = "Panther"
	elsif getType == "3"
	   type = "Squrrel"
	else
	   puts "That is not a valid option."
	   createNewPet("#{name}")
	end

        # Create newPet
        newPet = Pet.new("#{name}", "#{type}", 25)
        # Call menu
        newPet.petMenu
   end

   def loadPet
        puts "What is the name of the pet you would like to load?"
        print "> "
        name = gets.chomp()
        loadName = name.downcase
        # Check for saved file
        if not File.exist?(loadName)
           puts "Sorry, there's no load file for a pet with that name."
           puts "Would you like to create a pet with the the name #{name}?"
           puts "1: Yes"
           puts "2: No"
           print "> "
           createFromName = gets.chomp()
                if createFromName == "1"
                   createNewPet(name)
                elsif
                   gamePrompt
                end
        else
           loadInfo = IO.readlines(loadName)
           name = loadInfo[0].chomp
           type = loadInfo[1].chomp
           hitpoints = loadInfo[2].to_i
           # Create pet
           reloadPet = Pet.new(name, type, hitpoints)
           system("clear")
           # Call menu
           reloadPet.petMenu
        end
   end

# End StartGame class
end

class Battle

   def initialize(pet1Name, pet1Type, pet1Hp, pet2Name, pet2Type, pet2Hp)
        @pet1Name = pet1Name
	@pet1type = pet1Type
        @pet1Hp = pet1Hp
        @pet2Name = pet2Name
	@pet2Type = pet2Type
        @pet2Hp = pet2Hp
   end

   def fight

	   puts "The battle between #{@pet1Name} and #{@pet2Name} has begun!"

        while @pet1Hp > 0 and @pet2Hp > 0 do

           @hit1 = 1 + rand(5)
           @hit2 = 1 + rand(5)
           @pet1Hp = @pet1Hp - @hit2
           @pet2Hp = @pet2Hp - @hit1

           if @pet1Hp <= 0
                puts "#{@pet1Name} has #{@pet1Hp} hitpoints remaining!"
                puts "#{@pet2Name} has #{@pet2Hp} hitpoints remaining!"
		puts ""
		TrashTalk(@pet2Name, @pet1Name)
           elsif @pet2Hp <= 0                
                puts "#{@pet1Name} has #{@pet1Hp} hitpoints remaining!"
                puts "#{@pet2Name} has #{@pet2Hp} hitpoints remaining!"
		puts ""
                TrashTalk(@pet1Name, @pet2Name)
           elsif @pet1Hp <= 0 and @pet2Hp <= 0
                puts "#{@pet1Name} and #{@pet2Name} both fall down defeated!"
           else
                puts "#{@pet1Name} has #{@pet1Hp} hitpoints remaining!"
                puts "#{@pet2Name} has #{@pet2Hp} hitpoints remaining!"
                puts "They live to fight another round!!!"
		puts ""
           end
        end
	
	# Restore hitpoints (temporary?)
	@pet1Hp = 25
	@pet2Hp = 25
	
	# Call pet menu, but how?!?!
	postFight = Pet.new(@pet1Name, @pet1Type, @pet1Hp)
	postFight.petMenu
   end

   def  TrashTalk(winningPet, losingPet)

        phrase = 1 + rand(5)

        if phrase == 1
           puts "#{winningPet} destroys #{losingPet}!"
        elsif @phrase == 2
           puts "#{losingPet} falls defeated at the feet of the #{winningPet}"
        elsif @phrase == 3
           puts "#{winningPet} jeers at the dead body of #{losingPet}"
        elsif @phrase == 4
           puts "#{losingPet} crumples beneath the force of #{winningPet}"
        else
           puts "#{winningPet} dances victoriously around #{losingPet}'s corpse!"
        end
   end

# End Battle class
end

class Pet

   def initialize(name, type, hitpoints)
	@name = name
	@type = type
	@hitpoints = hitpoints
	@filename = name.downcase
   end

   def getStatus

	puts "#{@name}'s current status is:"
	puts "Current HP: #{@hitpoints}"
	petMenu
   end

   def petMenu

        puts ""
        puts ""
        puts "** Pet Activities Menu **"
        puts "1: Take #{@name} into battle!."
        puts "2: Create a new pet."
        puts "3: Check #{@name}'s current status."
        puts "4: Save and quit."
        puts ""
        puts "Enter a menu item number: "
        print "> "
        choice = gets.chomp()

        if choice == "1"
	   # Temp value for AI opponent		
           newFight = Battle.new(@name, @type, @hitpoints, "Fred", @type, 25)
	   newFight.fight
        elsif choice == "2"
           StartGame.createNewPet(" ")
        elsif choice == "3"
           getStatus
        elsif choice == "4"
           saveAndQuit
        else
           puts "That isn't a valid option."
           petMenu
        end
   end

   def saveAndQuit

       puts "Saving your pet. Enter its name to load it later!"
       loadPetFile = File.open(@filename, 'w')

        loadPetFile.write(@name)
        loadPetFile.write("\n")
        loadPetFile.write(@type)
        loadPetFile.write("\n")
        loadPetFile.write(@hitpoints)
	
        puts "Goodbye!"
        exit
   end

# End class Pet
end


#The end
